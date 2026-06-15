import 'package:flutter/material.dart';

import '../../../core/theme/tokens.dart';
import '../../../shared/widgets/widgets.dart';

class StepCalibration extends StatelessWidget {
  const StepCalibration({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: T.space5),
          Text('A first week of learning', style: T.h1),
          const SizedBox(height: T.space2),
          Text(
            'Pulse Edge spends its first seven days quietly building your '
            'usual range. During this period, alerts focus on readings that '
            'may need attention, not subtle pattern changes.',
            style: T.bodySoft,
          ),
          const SizedBox(height: T.space6),
          _Tip(
            n: '1',
            text:
                'Wear the device snugly above the wrist bone, sensor '
                'against the skin.',
          ),
          const SizedBox(height: T.space3),
          _Tip(
            n: '2',
            text:
                'For 24 h, do whatever you usually do - sit, walk, '
                'sleep, exercise.',
          ),
          const SizedBox(height: T.space3),
          _Tip(
            n: '3',
            text:
                'Do not over-analyse the readings during week one. '
                "They're inputs, not verdicts.",
          ),
          const SizedBox(height: T.space5),
          NeuCard(
            color: T.warningSoft,
            child: Row(
              children: [
                Icon(Icons.info_rounded, color: T.warning),
                const SizedBox(width: T.space3),
                Expanded(
                  child: Text(
                    'Pulse Edge is not a medical device. It does not '
                    'diagnose, treat, or prevent any condition.',
                    style: T.caption.copyWith(color: T.warning),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Tip extends StatelessWidget {
  const _Tip({required this.n, required this.text});
  final String n;
  final String text;

  @override
  Widget build(BuildContext context) {
    return NeuCard(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(color: T.primary, shape: BoxShape.circle),
            alignment: Alignment.center,
            child: Text(n, style: T.bodyStrong.copyWith(color: T.inkInverse)),
          ),
          const SizedBox(width: T.space4),
          Expanded(child: Text(text, style: T.body)),
        ],
      ),
    );
  }
}
