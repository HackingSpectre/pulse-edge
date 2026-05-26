import 'package:flutter/material.dart';

import '../../../core/theme/tokens.dart';
import '../../../shared/widgets/widgets.dart';

class StepValueProps extends StatelessWidget {
  const StepValueProps({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: T.space5),
          Text('What you get', style: T.h1),
          const SizedBox(height: T.space2),
          Text(
            'Pulse Edge is a wearable and an AI assistant. Both are quiet, both on '
            "your phone, both working when you're offline.",
            style: T.bodySoft,
          ),
          const SizedBox(height: T.space6),
          _ValueCard(
            icon: Icons.monitor_heart_rounded,
            color: T.danger,
            title: 'Live vitals',
            body:
                'Heart rate, oxygen, skin temperature and movement, '
                'updated every quarter-second via Bluetooth.',
          ),
          const SizedBox(height: T.space4),
          _ValueCard(
            icon: Icons.show_chart_rounded,
            color: T.primary,
            title: 'Personal baseline',
            body:
                'After a week the app learns your usual rhythm by '
                'time-of-day and activity, instead of comparing you to '
                'a population average.',
          ),
          const SizedBox(height: T.space4),
          _ValueCard(
            icon: Icons.notifications_active_rounded,
            color: T.warning,
            title: 'Quiet alerts',
            body:
                'Two layers of safety nets: a hard rule book and a learned '
                'pattern model. Only sustained 30-second windows trigger.',
          ),
          const SizedBox(height: T.space4),
          _ValueCard(
            icon: Icons.chat_bubble_rounded,
            color: T.info,
            title: 'On-device assistant',
            body:
                'Download the offline edge model to ask richer questions '
                'about your data on this phone.',
          ),
          const SizedBox(height: T.space5),
        ],
      ),
    );
  }
}

class _ValueCard extends StatelessWidget {
  const _ValueCard({
    required this.icon,
    required this.color,
    required this.title,
    required this.body,
  });

  final IconData icon;
  final Color color;
  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    return NeuCard(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.14),
              borderRadius: T.brSm,
            ),
            child: Icon(icon, size: T.iconMd, color: color),
          ),
          const SizedBox(width: T.space4),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: T.h3),
                const SizedBox(height: T.space1),
                Text(body, style: T.bodySoft),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
