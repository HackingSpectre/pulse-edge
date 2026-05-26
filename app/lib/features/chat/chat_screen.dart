import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/router.dart';
import '../../core/llm/llm_service.dart';
import '../../core/providers.dart';
import '../../core/theme/tokens.dart';
import '../../shared/widgets/widgets.dart';

class ChatScreen extends ConsumerStatefulWidget {
  const ChatScreen({super.key});

  @override
  ConsumerState<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<ChatScreen> {
  final _input = TextEditingController();
  final _scroll = ScrollController();
  final _messages = <_Msg>[
    _Msg(
      role: _Role.assistant,
      text:
          'Hi. I am your on-device assistant. Ask me about your wearable '
          'data, or pick a suggestion below.',
    ),
  ];
  bool _busy = false;
  StreamSubscription<String>? _stream;

  @override
  void initState() {
    super.initState();
    // Start loading the model in the background. This will not block UI.
    Future.microtask(() => ref.read(llmServiceProvider).ensureLoaded());
  }

  @override
  void dispose() {
    _input.dispose();
    _scroll.dispose();
    _stream?.cancel();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scroll.hasClients) {
        _scroll.animateTo(
          _scroll.position.maxScrollExtent + 80,
          duration: T.motionBase,
          curve: T.emphasized,
        );
      }
    });
  }

  Future<void> _send([String? presetText]) async {
    final text = (presetText ?? _input.text).trim();
    if (text.isEmpty || _busy) return;
    _input.clear();
    setState(() {
      _messages.add(_Msg(role: _Role.user, text: text));
      _messages.add(_Msg(role: _Role.assistant, text: '', streaming: true));
      _busy = true;
    });
    _scrollToBottom();

    final llm = ref.read(llmServiceProvider);
    final buf = StringBuffer();
    _stream = llm
        .chat(text)
        .listen(
          (chunk) {
            buf.write(chunk);
            setState(() {
              _messages.last = _Msg(
                role: _Role.assistant,
                text: buf.toString(),
                streaming: true,
              );
            });
            _scrollToBottom();
          },
          onDone: () {
            setState(() {
              _messages.last = _Msg(
                role: _Role.assistant,
                text: buf.toString(),
              );
              _busy = false;
            });
            _scrollToBottom();
          },
          onError: (Object e) {
            setState(() {
              _messages.last = _Msg(
                role: _Role.assistant,
                text: 'Sorry, something went wrong: $e',
              );
              _busy = false;
            });
          },
        );
  }

  @override
  Widget build(BuildContext context) {
    return NeuScaffold(
      title: 'Assistant',
      actions: [
        NeuIconButton(
          icon: Icons.tune_rounded,
          tooltip: 'Model',
          onPressed: () => context.go(Routes.settingsModel),
        ),
      ],
      padding: EdgeInsets.zero,
      body: Column(
        children: [
          const _StatusBanner(),
          Expanded(
            child: ListView.builder(
              controller: _scroll,
              padding: const EdgeInsets.fromLTRB(
                T.pagePadding,
                T.space3,
                T.pagePadding,
                T.space5,
              ),
              itemCount: _messages.length,
              itemBuilder: (context, i) => _Bubble(msg: _messages[i]),
            ),
          ),
          if (_messages.length <= 2) _Suggestions(onTap: _send),
          _Composer(controller: _input, busy: _busy, onSend: () => _send()),
        ],
      ),
    );
  }
}

enum _Role { user, assistant }

class _Msg {
  _Msg({required this.role, required this.text, this.streaming = false});
  final _Role role;
  final String text;
  final bool streaming;
}

class _StatusBanner extends ConsumerWidget {
  const _StatusBanner();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final llm = ref.watch(llmServiceProvider);
    return StreamBuilder<LlmStatus>(
      stream: llm.status$,
      initialData: llm.status,
      builder: (context, snap) {
        final s = snap.data!;
        if (s == LlmStatus.ready) return const SizedBox.shrink();
        final color = switch (s) {
          LlmStatus.loadingModel => T.warning,
          LlmStatus.missingModel => T.info,
          LlmStatus.failed => T.danger,
          _ => T.inkMuted,
        };
        final label = switch (s) {
          LlmStatus.loadingModel => 'Warming up the assistant…',
          LlmStatus.missingModel =>
            'Rule-based assistant active. Download the offline edge model for richer chat.',
          LlmStatus.failed =>
            'Assistant failed to load. Tap settings to retry.',
          _ => '',
        };
        return Padding(
          padding: const EdgeInsets.fromLTRB(
            T.pagePadding,
            T.space3,
            T.pagePadding,
            0,
          ),
          child: NeuCard(
            color: color.withValues(alpha: 0.10),
            padding: const EdgeInsets.all(T.space3),
            child: Row(
              children: [
                Icon(Icons.info_rounded, size: T.iconSm, color: color),
                const SizedBox(width: T.space2),
                Expanded(
                  child: Text(label, style: T.caption.copyWith(color: color)),
                ),
                if (s == LlmStatus.missingModel)
                  GestureDetector(
                    onTap: () => context.go(Routes.settingsModel),
                    child: Text(
                      'INSTALL',
                      style: T.label.copyWith(color: color),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _Bubble extends StatelessWidget {
  const _Bubble({required this.msg});
  final _Msg msg;

  @override
  Widget build(BuildContext context) {
    final isUser = msg.role == _Role.user;
    final bg = isUser ? T.primary : null;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: T.space2),
      child: Align(
        alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: MediaQuery.of(context).size.width * 0.86,
          ),
          child: NeuSurface(
            depth: NeuDepth.raised,
            size: NeuSize.sm,
            borderRadius: BorderRadius.only(
              topLeft: T.rLg,
              topRight: T.rLg,
              bottomLeft: isUser ? T.rLg : T.rXs,
              bottomRight: isUser ? T.rXs : T.rLg,
            ),
            color: bg,
            padding: const EdgeInsets.symmetric(
              horizontal: T.space4,
              vertical: T.space3,
            ),
            child: Text(
              msg.text + (msg.streaming ? ' ▍' : ''),
              style: T.body.copyWith(
                color: isUser ? T.inkInverse : T.ink,
                height: 1.45,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _Suggestions extends StatelessWidget {
  const _Suggestions({required this.onTap});
  final ValueChanged<String> onTap;

  static const _options = [
    'How is my heart rate today?',
    'Explain my last alert',
    'What does HRV mean?',
  ];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: T.pagePadding,
        vertical: T.space2,
      ),
      child: Wrap(
        spacing: T.space2,
        runSpacing: T.space2,
        children: [
          for (final s in _options)
            NeuChip(label: s, onPressed: () => onTap(s), compact: true),
        ],
      ),
    );
  }
}

class _Composer extends StatelessWidget {
  const _Composer({
    required this.controller,
    required this.busy,
    required this.onSend,
  });
  final TextEditingController controller;
  final bool busy;
  final VoidCallback onSend;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        T.pagePadding,
        T.space2,
        T.pagePadding,
        T.space4,
      ),
      child: Row(
        children: [
          Expanded(
            child: NeuTextField(
              controller: controller,
              hint: 'Ask anything…',
              minLines: 1,
              maxLines: 4,
              textInputAction: TextInputAction.send,
              onSubmitted: (_) => onSend(),
            ),
          ),
          const SizedBox(width: T.space3),
          NeuIconButton(
            icon: Icons.send_rounded,
            onPressed: busy ? null : onSend,
            color: busy ? T.inkDisabled : T.primary,
            tooltip: 'Send',
          ),
        ],
      ),
    );
  }
}
