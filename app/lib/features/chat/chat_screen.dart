import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/router.dart';
import '../../core/providers.dart';
import '../../core/theme/tokens.dart';
import '../../shared/widgets/widgets.dart';

class ChatScreen extends ConsumerStatefulWidget {
  const ChatScreen({super.key});

  @override
  ConsumerState<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<ChatScreen> {
  static const _thinkingDelay = Duration(milliseconds: 750);
  static const _typingDelay = Duration(milliseconds: 22);
  static const _typingStep = 4;

  final _input = TextEditingController();
  final _scroll = ScrollController();
  final _messages = <_Msg>[
    _Msg(
      role: _Role.assistant,
      text:
          'Hi. I can help explain your wearable readings, alerts, and '
          'today\'s health trends.',
    ),
  ];
  bool _busy = false;
  StreamSubscription<String>? _stream;
  int _replyToken = 0;

  @override
  void initState() {
    super.initState();
    // Initializes the lightweight local assistant state.
    Future.microtask(() => ref.read(llmServiceProvider).ensureLoaded());
  }

  @override
  void dispose() {
    _input.dispose();
    _scroll.dispose();
    _replyToken++;
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
    final token = ++_replyToken;
    setState(() {
      _messages.add(_Msg(role: _Role.user, text: text));
      _messages.add(
        _Msg(role: _Role.assistant, text: '', phase: _MsgPhase.thinking),
      );
      _busy = true;
    });
    _scrollToBottom();

    final llm = ref.read(llmServiceProvider);
    final responseFuture = _collectReply(llm.chat(text));

    try {
      await Future.delayed(_thinkingDelay);
      final reply = await responseFuture;
      if (!mounted || token != _replyToken) return;
      await _revealReply(reply, token);
    } catch (_) {
      if (!mounted || token != _replyToken) return;
      setState(() {
        _messages.last = _Msg(
          role: _Role.assistant,
          text: 'Sorry, I could not answer that right now.',
        );
        _busy = false;
      });
      _scrollToBottom();
    }
  }

  Future<String> _collectReply(Stream<String> stream) {
    final completer = Completer<String>();
    final buf = StringBuffer();
    _stream?.cancel();
    _stream = stream.listen(
      buf.write,
      onDone: () => completer.complete(buf.toString()),
      onError: completer.completeError,
      cancelOnError: true,
    );
    return completer.future;
  }

  Future<void> _revealReply(String reply, int token) async {
    final text = reply.trim().isEmpty
        ? 'I do not have enough information to answer that yet.'
        : reply;
    for (var end = _typingStep; end < text.length; end += _typingStep) {
      if (!mounted || token != _replyToken) return;
      setState(() {
        _messages.last = _Msg(
          role: _Role.assistant,
          text: text.substring(0, end),
          phase: _MsgPhase.typing,
        );
      });
      _scrollToBottom();
      await Future.delayed(_typingDelay);
    }
    if (!mounted || token != _replyToken) return;
    setState(() {
      _messages.last = _Msg(role: _Role.assistant, text: text);
      _busy = false;
    });
    _scrollToBottom();
  }

  @override
  Widget build(BuildContext context) {
    return NeuScaffold(
      title: 'Assistant',
      actions: [
        NeuIconButton(
          icon: Icons.tune_rounded,
          tooltip: 'Health guidance',
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

enum _MsgPhase { idle, thinking, typing }

class _Msg {
  _Msg({required this.role, required this.text, this.phase = _MsgPhase.idle});
  final _Role role;
  final String text;
  final _MsgPhase phase;
}

class _StatusBanner extends ConsumerWidget {
  const _StatusBanner();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return const SizedBox.shrink();
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
            child: AnimatedSwitcher(
              duration: T.motionFast,
              switchInCurve: T.emphasized,
              switchOutCurve: Curves.easeOut,
              child: msg.phase == _MsgPhase.thinking
                  ? const _ThinkingDots()
                  : Text(
                      msg.text + (msg.phase == _MsgPhase.typing ? ' ▍' : ''),
                      key: ValueKey(msg.text.isEmpty ? 'empty' : 'reply'),
                      style: T.body.copyWith(
                        color: isUser ? T.inkInverse : T.ink,
                        height: 1.45,
                      ),
                    ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ThinkingDots extends StatefulWidget {
  const _ThinkingDots();

  @override
  State<_ThinkingDots> createState() => _ThinkingDotsState();
}

class _ThinkingDotsState extends State<_ThinkingDots>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: T.motionSlow)
      ..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (var i = 0; i < 3; i++) ...[
              _Dot(active: ((_controller.value * 3).floor() % 3) == i),
              if (i != 2) const SizedBox(width: 5),
            ],
          ],
        );
      },
    );
  }
}

class _Dot extends StatelessWidget {
  const _Dot({required this.active});
  final bool active;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: T.motionFast,
      curve: T.emphasized,
      width: active ? 8 : 6,
      height: active ? 8 : 6,
      decoration: BoxDecoration(
        color: active ? T.primary : T.inkMuted.withValues(alpha: 0.45),
        shape: BoxShape.circle,
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
