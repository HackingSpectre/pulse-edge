import 'package:flutter/material.dart';

import '../../../core/theme/tokens.dart';
import '../../../shared/widgets/widgets.dart';

class StepIntro extends StatelessWidget {
  const StepIntro({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: T.space7),
          NeuSurface(
            depth: NeuDepth.raised,
            size: NeuSize.lg,
            borderRadius: BorderRadius.circular(80),
            padding: const EdgeInsets.all(T.space7),
            child: Icon(Icons.favorite_rounded, size: 56, color: T.primary),
          ),
          const SizedBox(height: T.space7),
          Text('Welcome to', style: T.bodySoft),
          const SizedBox(height: T.space2),
          Text('Pulse Edge', style: T.display1),
          const SizedBox(height: T.space4),
          Text(
            'A private, on-device wellness companion that reads your wearable, '
            'learns your normal, and quietly flags what looks unusual.',
            style: T.body.copyWith(
              color: T.inkSoft,
              fontSize: 15,
              height: 1.55,
            ),
          ),
          const SizedBox(height: T.space7),
          _Pill(icon: Icons.cloud_off_rounded, label: 'Works fully offline'),
          const SizedBox(height: T.space3),
          _Pill(
            icon: Icons.lock_rounded,
            label: 'Your data never leaves your phone',
          ),
          const SizedBox(height: T.space3),
          _Pill(
            icon: Icons.psychology_rounded,
            label: 'Private guidance on your phone',
          ),
        ],
      ),
    );
  }
}

class _Pill extends StatelessWidget {
  const _Pill({required this.icon, required this.label});
  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return NeuSurface(
      depth: NeuDepth.raised,
      size: NeuSize.sm,
      borderRadius: T.brPill,
      padding: const EdgeInsets.symmetric(
        horizontal: T.space5,
        vertical: T.space3 + 2,
      ),
      child: Row(
        children: [
          Icon(icon, size: T.iconSm, color: T.primary),
          const SizedBox(width: T.space3),
          Expanded(
            child: Text(label, style: T.bodyStrong.copyWith(fontSize: 13)),
          ),
        ],
      ),
    );
  }
}
