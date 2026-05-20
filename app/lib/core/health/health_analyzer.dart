import 'package:flutter/material.dart';

import '../theme/tokens.dart';

enum HealthLevel {
  stable('Stable', T.success),
  watch('Watch', T.info),
  caution('Caution', T.warning),
  attention('Attention', T.danger);

  const HealthLevel(this.label, this.color);
  final String label;
  final Color color;
}

class HealthAssessment {
  const HealthAssessment({
    required this.level,
    required this.score,
    required this.title,
    required this.summary,
    required this.reasons,
  });

  final HealthLevel level;
  final int score;
  final String title;
  final String summary;
  final List<String> reasons;
}

class HealthAnalyzer {
  HealthAnalyzer._();

  static HealthAssessment assessLatest({
    double? hr,
    double? spo2,
    double? temp,
    int activity = 0,
    double? motion,
    bool? sensorOk,
    bool? contactOk,
    int recentHighAlerts = 0,
    int recentMediumAlerts = 0,
  }) {
    var penalty = 0;
    final reasons = <String>[];

    if (sensorOk == false) {
      penalty += 18;
      reasons.add('One or more wearable sensors need attention.');
    }
    if (contactOk == false) {
      penalty += 12;
      reasons.add('Wrist contact is weak, so optical readings may be noisy.');
    }

    if (hr == null) {
      penalty += 8;
      reasons.add('Heart-rate data is still warming up.');
    } else if (hr >= 180 || hr <= 35) {
      penalty += 45;
      reasons.add('Heart rate is outside the sustained safety band.');
    } else if (hr >= 140 && activity < 2) {
      penalty += 26;
      reasons.add('Heart rate is high for the current activity level.');
    } else if (hr >= 120 && activity == 0) {
      penalty += 18;
      reasons.add('Resting heart rate is elevated.');
    } else if (hr < 50 && activity == 0) {
      penalty += 10;
      reasons.add(
        'Resting heart rate is low; compare with your normal baseline.',
      );
    }

    if (spo2 != null) {
      if (spo2 <= 90) {
        penalty += 45;
        reasons.add('Blood oxygen is below the safety threshold.');
      } else if (spo2 < 95) {
        penalty += 18;
        reasons.add('Blood oxygen is lower than typical resting range.');
      }
    }

    if (temp != null) {
      if (temp >= 39.5 || temp <= 34) {
        penalty += 34;
        reasons.add('Skin temperature is outside the expected wearable range.');
      } else if (temp >= 37.5 || temp < 35) {
        penalty += 12;
        reasons.add('Skin temperature is drifting from the usual range.');
      }
    }

    if (motion != null && motion > 2.8) {
      penalty += 10;
      reasons.add(
        'Motion intensity is high; HR changes may be activity-related.',
      );
    }

    penalty += recentHighAlerts * 22 + recentMediumAlerts * 10;
    if (recentHighAlerts > 0) {
      reasons.add('A high-severity alert appeared recently.');
    } else if (recentMediumAlerts > 0) {
      reasons.add('A medium-severity pattern was logged recently.');
    }

    final score = (100 - penalty).clamp(0, 100);
    final level = switch (score) {
      >= 86 => HealthLevel.stable,
      >= 70 => HealthLevel.watch,
      >= 50 => HealthLevel.caution,
      _ => HealthLevel.attention,
    };

    final title = switch (level) {
      HealthLevel.stable => 'Vitals look steady',
      HealthLevel.watch => 'Keep watching trends',
      HealthLevel.caution => 'A few signals need attention',
      HealthLevel.attention => 'Review your current readings',
    };

    final summary = switch (level) {
      HealthLevel.stable =>
        'The latest wearable signals are within expected ranges.',
      HealthLevel.watch =>
        'Most signals are acceptable, with one or two values worth monitoring.',
      HealthLevel.caution =>
        'Pulse Edge sees a combination of readings that should be rechecked.',
      HealthLevel.attention =>
        'The combined sensor picture deserves prompt attention.',
    };

    return HealthAssessment(
      level: level,
      score: score,
      title: title,
      summary: summary,
      reasons: reasons.isEmpty
          ? const ['No unusual sustained pattern is visible right now.']
          : reasons.take(3).toList(growable: false),
    );
  }
}
