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
                icon: Icons.code_rounded,
                title: 'Source code',
                subtitle: 'Final-year project. See the project README',
              ),
              NeuListTile(
                icon: Icons.dataset_rounded,
                title: 'Trained on WESAD',
                subtitle: 'Schmidt et al., 2018 public dataset',
              ),
              NeuListTile(
                icon: Icons.psychology_rounded,
                title: 'Assistant',
                subtitle: 'Offline edge model support',
              ),
              NeuListTile(
                icon: Icons.style_rounded,
                title: 'Design language',
                subtitle: 'Neumorphism Club design system',
              ),
              NeuListTile(
                icon: Icons.gavel_rounded,
                title: 'Open-source licenses',
                subtitle: 'View the third-party software used',
                onTap: () => showLicensePage(
                  context: context,
                  applicationName: 'Pulse Edge',
                  applicationVersion: '0.1.0',
                ),
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
