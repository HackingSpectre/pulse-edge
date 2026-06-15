import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/router.dart';
import '../../core/llm/llm_service.dart';
import '../../core/providers.dart';
import '../../core/theme/tokens.dart';
import '../../shared/widgets/widgets.dart';

class ModelSettingsScreen extends ConsumerWidget {
  const ModelSettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final assistant = ref.watch(llmServiceProvider);
    return NeuScaffold(
      title: 'Health guidance',
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
                Row(
                  children: [
                    Icon(Icons.health_and_safety_rounded, color: T.primary),
                    const SizedBox(width: T.space3),
                    Expanded(child: Text('How guidance works', style: T.h3)),
                  ],
                ),
                const SizedBox(height: T.space3),
                Text(
                  'Pulse Edge uses your recent readings and clear safety '
                  'checks to explain alerts in plain language. It does not '
                  'diagnose conditions.',
                  style: T.body.copyWith(color: T.inkSoft),
                ),
              ],
            ),
          ),
          const SizedBox(height: T.space5),
          StreamBuilder<LlmStatus>(
            stream: assistant.status$,
            initialData: assistant.status,
            builder: (context, snap) {
              return NeuCard(
                color: T.successSoft,
                child: Row(
                  children: [
                    Icon(Icons.check_circle_rounded, color: T.success),
                    const SizedBox(width: T.space3),
                    Expanded(
                      child: Text(
                        'Ready to explain your readings',
                        style: T.bodyStrong.copyWith(color: T.success),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
          const SizedBox(height: T.space5),
          Text('WHAT IT LOOKS AT', style: T.label),
          const SizedBox(height: T.space2),
          NeuListGroup(
            children: const [
              NeuListTile(
                icon: Icons.health_and_safety_rounded,
                title: 'Safety checks',
                subtitle:
                    'Looks for readings that may need attention, such as very high heart rate or low blood oxygen.',
              ),
              NeuListTile(
                icon: Icons.directions_walk_rounded,
                title: 'Activity context',
                subtitle:
                    'Interprets heart rate together with rest, walking, running, and movement.',
              ),
              NeuListTile(
                icon: Icons.auto_graph_rounded,
                title: 'Your usual patterns',
                subtitle:
                    'After enough history, compares new readings with your normal day-to-day range.',
              ),
              NeuListTile(
                icon: Icons.psychology_rounded,
                title: 'Plain-language replies',
                subtitle:
                    'Gives short explanations and practical next steps from your local readings.',
              ),
            ],
          ),
          const SizedBox(height: T.space5),
          Text('IMPORTANT NOTE', style: T.label),
          const SizedBox(height: T.space2),
          NeuListGroup(
            children: const [
              NeuListTile(
                icon: Icons.medical_information_rounded,
                title: 'When to contact a doctor',
                subtitle:
                    'If you feel unwell or readings stay unusual, contact a healthcare professional.',
              ),
            ],
          ),
        ],
      ),
    );
  }
}
