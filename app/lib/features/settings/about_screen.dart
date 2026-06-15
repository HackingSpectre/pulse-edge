import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../app/router.dart';
import '../../core/theme/tokens.dart';
import '../../shared/widgets/widgets.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return NeuScaffold(
      title: 'About',
      showBack: true,
      onBack: () => context.go(Routes.settings),
      scrollable: true,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          NeuCard(
            child: Column(
              children: [
                NeuSurface(
                  depth: NeuDepth.raised,
                  size: NeuSize.lg,
                  borderRadius: BorderRadius.circular(60),
                  padding: const EdgeInsets.all(T.space5),
                  child: Icon(
                    Icons.favorite_rounded,
                    size: 40,
                    color: T.primary,
                  ),
                ),
                const SizedBox(height: T.space4),
                Text('Pulse Edge', style: T.h1),
                const SizedBox(height: T.space1),
                Text('Version 0.1.0', style: T.caption),
              ],
            ),
          ),
          const SizedBox(height: T.space5),
          NeuListGroup(
            children: [
              NeuListTile(
                icon: Icons.monitor_heart_rounded,
                title: 'Wearable monitoring',
                subtitle:
                    'Tracks readings, trends, alerts, and health summaries.',
              ),
              NeuListTile(
                icon: Icons.psychology_rounded,
                title: 'Private guidance',
                subtitle:
                    'Explains readings on your phone using recent health data.',
              ),
              NeuListTile(
                icon: Icons.shield_rounded,
                title: 'Privacy first',
                subtitle:
                    'Your readings stay on this phone unless you share them.',
              ),
            ],
          ),
          const SizedBox(height: T.space5),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: T.space3),
            child: Text(
              'Pulse Edge is not a medical device. It does not diagnose, '
              'treat, or prevent any condition. If you feel unwell, contact '
              'a healthcare professional.',
              textAlign: TextAlign.center,
              style: T.caption.copyWith(color: T.inkMuted),
            ),
          ),
        ],
      ),
    );
  }
}
