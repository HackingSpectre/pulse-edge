import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/router.dart';
import '../../core/providers.dart';
import '../../core/theme/tokens.dart';
import '../../shared/widgets/widgets.dart';

class CalibrationScreen extends ConsumerStatefulWidget {
  const CalibrationScreen({super.key});

  @override
  ConsumerState<CalibrationScreen> createState() => _CalibrationScreenState();
}

class _CalibrationScreenState extends ConsumerState<CalibrationScreen> {
  bool? _warmedUp;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final w = await ref.read(baselineServiceProvider).warmedUp();
      if (mounted) setState(() => _warmedUp = w);
    });
  }

  @override
  Widget build(BuildContext context) {
    return NeuScaffold(
      title: 'Personal baseline',
      showBack: true,
      onBack: () => context.go(Routes.settings),
      scrollable: true,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          NeuCard(
            color: _warmedUp == true ? T.successSoft : T.warningSoft,
            child: Row(
              children: [
                Icon(
                  _warmedUp == true
                      ? Icons.check_circle_rounded
                      : Icons.hourglass_top_rounded,
                  color: _warmedUp == true ? T.success : T.warning,
                ),
                const SizedBox(width: T.space3),
                Expanded(
                  child: Text(
                    _warmedUp == null
                        ? 'Loading…'
                        : (_warmedUp!
                              ? 'Baseline established. Pattern detector is on.'
                              : 'Still learning. The first 7 days build your baseline.'),
                    style: T.bodyStrong.copyWith(
                      color: _warmedUp == true ? T.success : T.warning,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: T.space5),
          NeuCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('How it works'.toUpperCase(), style: T.label),
                const SizedBox(height: T.space3),
                Text(
                  'Pulse Edge keeps a running average and standard deviation '
                  'of your heart rate, RMSSD, temperature, and SpO₂, broken '
                  'down by time-of-day and current activity. After about a '
                  'week the second-tier pattern detector starts comparing '
                  'live readings to your own usual values, instead of only '
                  'the hard safety thresholds.',
                  style: T.body,
                ),
              ],
            ),
          ),
          const SizedBox(height: T.space5),
          NeuButton(
            label: 'Recalibrate from scratch',
            icon: Icons.restart_alt_rounded,
            variant: NeuButtonVariant.danger,
            onPressed: () async {
              await ref.read(baselineServiceProvider).reset();
              if (!context.mounted) return;
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Baseline cleared.')),
              );
              setState(() => _warmedUp = false);
            },
          ),
        ],
      ),
    );
  }
}
