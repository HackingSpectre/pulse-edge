import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/router.dart';
import '../../core/llm/llm_service.dart';
import '../../core/llm/model_download_manager.dart';
import '../../core/providers.dart';
import '../../core/theme/tokens.dart';
import '../../shared/widgets/widgets.dart';

class ModelSettingsScreen extends ConsumerWidget {
  const ModelSettingsScreen({super.key});

  String _bytes(int b) {
    if (b < 1024) return '$b B';
    if (b < 1024 * 1024) return '${(b / 1024).toStringAsFixed(0)} KB';
    if (b < 1024 * 1024 * 1024) {
      return '${(b / (1024 * 1024)).toStringAsFixed(1)} MB';
    }
    return '${(b / (1024 * 1024 * 1024)).toStringAsFixed(2)} GB';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dl = ref.watch(modelDownloadProvider);
    final llm = ref.watch(llmServiceProvider);
    return NeuScaffold(
      title: 'AI assistant',
      showBack: true,
      onBack: () => context.go(Routes.settings),
      scrollable: true,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          NeuCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(dl.bundle.name, style: T.h3),
                const SizedBox(height: 2),
                Text(dl.bundle.notes, style: T.caption),
                const SizedBox(height: T.space3),
                Row(
                  children: [
                    const Icon(Icons.cloud_download_rounded,
                        size: T.iconSm, color: T.inkMuted),
                    const SizedBox(width: T.space2),
                    Text(_bytes(dl.bundle.sizeBytes), style: T.caption),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: T.space4),
          StreamBuilder<DownloadProgress>(
            stream: dl.progress$,
            initialData: dl.progress,
            builder: (context, snap) {
              final p = snap.data!;
              switch (p.state) {
                case DownloadState.idle:
                  return _ActionBlock(
                    title: 'Not installed',
                    subtitle:
                        'The assistant runs on your phone — no servers, no '
                        'subscriptions. Around 720 MB to download once.',
                    primary: NeuButton(
                      label: 'Download now',
                      icon: Icons.download_rounded,
                      variant: NeuButtonVariant.filled,
                      expanded: true,
                      onPressed: dl.start,
                    ),
                  );
                case DownloadState.downloading:
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      NeuLinearProgress(value: p.fraction),
                      const SizedBox(height: T.space2),
                      Row(
                        children: [
                          Text('${(p.fraction * 100).toStringAsFixed(0)}%',
                              style: T.bodyStrong),
                          const Spacer(),
                          Text(
                            '${_bytes(p.received)} / ${_bytes(p.total)}',
                            style: T.caption,
                          ),
                        ],
                      ),
                      const SizedBox(height: T.space4),
                      NeuButton(
                        label: 'Pause',
                        icon: Icons.pause_rounded,
                        variant: NeuButtonVariant.subtle,
                        onPressed: dl.pause,
                      ),
                    ],
                  );
                case DownloadState.paused:
                  return _ActionBlock(
                    title: 'Paused',
                    subtitle:
                        'Resumes from ${_bytes(p.received)} when you tap continue.',
                    primary: NeuButton(
                      label: 'Continue',
                      icon: Icons.play_arrow_rounded,
                      variant: NeuButtonVariant.filled,
                      expanded: true,
                      onPressed: dl.start,
                    ),
                  );
                case DownloadState.failed:
                  return _ActionBlock(
                    title: 'Download failed',
                    subtitle: p.error ?? 'Unknown error',
                    primary: NeuButton(
                      label: 'Try again',
                      icon: Icons.refresh_rounded,
                      variant: NeuButtonVariant.filled,
                      expanded: true,
                      onPressed: dl.start,
                    ),
                  );
                case DownloadState.complete:
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      NeuCard(
                        color: T.successSoft,
                        child: Row(
                          children: [
                            const Icon(Icons.check_circle_rounded,
                                color: T.success),
                            const SizedBox(width: T.space3),
                            Expanded(
                              child: Text(
                                'Installed (${_bytes(p.received)})',
                                style: T.bodyStrong.copyWith(color: T.success),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: T.space4),
                      Row(
                        children: [
                          Expanded(
                            child: NeuButton(
                              label: 'Replace',
                              icon: Icons.refresh_rounded,
                              variant: NeuButtonVariant.subtle,
                              onPressed: () async {
                                await dl.delete();
                                await dl.start();
                              },
                            ),
                          ),
                          const SizedBox(width: T.space3),
                          Expanded(
                            child: NeuButton(
                              label: 'Remove',
                              icon: Icons.delete_outline_rounded,
                              variant: NeuButtonVariant.danger,
                              onPressed: dl.delete,
                            ),
                          ),
                        ],
                      ),
                    ],
                  );
              }
            },
          ),
          const SizedBox(height: T.space5),
          StreamBuilder<LlmStatus>(
            stream: llm.status$,
            initialData: llm.status,
            builder: (context, snap) {
              final s = snap.data!;
              final color = switch (s) {
                LlmStatus.ready => T.success,
                LlmStatus.loadingModel => T.warning,
                LlmStatus.failed => T.danger,
                _ => T.inkMuted,
              };
              final label = switch (s) {
                LlmStatus.uninitialized => 'Not loaded yet',
                LlmStatus.loadingModel => 'Loading…',
                LlmStatus.ready => 'Ready',
                LlmStatus.missingModel => 'Model not installed',
                LlmStatus.failed => 'Failed to load',
              };
              return NeuCard(
                child: Row(
                  children: [
                    Container(
                      width: 10,
                      height: 10,
                      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
                    ),
                    const SizedBox(width: T.space3),
                    Expanded(child: Text('Runtime: $label', style: T.bodyStrong)),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _ActionBlock extends StatelessWidget {
  const _ActionBlock({
    required this.title,
    required this.subtitle,
    required this.primary,
  });

  final String title;
  final String subtitle;
  final Widget primary;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        NeuCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title.toUpperCase(), style: T.label),
              const SizedBox(height: T.space2),
              Text(subtitle, style: T.body),
            ],
          ),
        ),
        const SizedBox(height: T.space4),
        primary,
      ],
    );
  }
}
