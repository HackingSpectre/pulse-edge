import 'dart:math' as math;

/// Deterministic fallback used when the on-device Gemma model is not installed.
///
/// This is not a diagnosis engine. It is a compact rule-based explainer that
/// grounds answers in the user's recent local wearable data.
class ScriptedAssistant {
  static String reply(String userMessage, {HealthChatContext? context}) {
    final m = userMessage.toLowerCase();
    final ctx = context ?? const HealthChatContext.empty();

    if (_any(m, [
      'chest pain',
      'faint',
      'fainted',
      'can\'t breathe',
      'cant breathe',
      'shortness of breath',
    ])) {
      return 'Those symptoms can be urgent. Pulse Edge cannot diagnose you, but you should seek medical help now, especially if symptoms are severe, new, or worsening.\n\n${ctx.shortSummary}';
    }

    if (_any(m, [
      'how am i',
      'health status',
      'status',
      'am i okay',
      'today',
      'summary',
    ])) {
      return '${ctx.statusLine}\n\n${ctx.compactBullets}\n\n${_nextStep(ctx)}';
    }

    if (_any(m, ['heart', 'hr', 'bpm', 'pulse', 'tachy', 'brady'])) {
      return '${ctx.hrLine}\n\n${_heartGuidance(ctx)}';
    }

    if (_any(m, ['oxygen', 'spo2', 'sp02', 'breath', 'hypoxia'])) {
      return '${ctx.spo2Line}\n\n${_oxygenGuidance(ctx)}';
    }

    if (_any(m, ['temperature', 'temp', 'fever', 'hot', 'cold'])) {
      return '${ctx.tempLine}\n\nSkin temperature is best used as a trend, because a wrist sensor usually reads lower than core body temperature.';
    }

    if (_any(m, [
      'motion',
      'activity',
      'walk',
      'run',
      'fall',
      'movement',
      'accelerometer',
      'gyro',
    ])) {
      return '${ctx.motionLine}\n\nMotion helps Pulse Edge decide whether a high heart rate looks activity-related or unusual for rest.';
    }

    if (_any(m, ['alert', 'anomaly', 'warning', 'notification'])) {
      return '${ctx.alertLine}\n\nAlerts are based on sustained windows, not single noisy samples. Open the Alerts tab for the exact metrics and explanation.';
    }

    if (_any(m, ['model', 'gemma', 'download', 'ai assistant', 'offline'])) {
      return 'You are using the rule-based assistant right now. It can explain recent wearable patterns using local rules, but installing the Gemma model unlocks more flexible conversation while still keeping data on your phone.';
    }

    if (_any(m, ['privacy', 'cloud', 'internet', 'server'])) {
      return 'Pulse Edge is designed offline-first. Sensor history, baseline learning, alerts, and this fallback assistant run on your phone. Internet is only needed if you choose to download the local AI model.';
    }

    if (_any(m, ['what should i do', 'advice', 'help me', 'recommend'])) {
      return '${_nextStep(ctx)}\n\n${ctx.compactBullets}';
    }

    return 'I can help with heart rate, SpO2, skin temperature, motion, alerts, privacy, and today\'s health status.\n\n${ctx.shortSummary}';
  }

  static bool _any(String text, List<String> terms) => terms.any(text.contains);

  static String _nextStep(HealthChatContext c) {
    if (c.recentHighAlerts > 0 || c.spo2Min != null && c.spo2Min! <= 90) {
      return 'Next step: sit down, re-check the wearable fit, and get medical help if you feel unwell or the reading persists.';
    }
    if (c.hrMax != null &&
        c.hrMax! >= 140 &&
        c.motionMean != null &&
        c.motionMean! < 1.3) {
      return 'Next step: rest for a few minutes and watch whether heart rate returns toward your usual range.';
    }
    if (c.sampleCount == 0) {
      return 'Next step: keep the wearable connected for a few minutes so I can reason from real readings.';
    }
    return 'Next step: keep monitoring trends. If symptoms appear or readings stay unusual, contact a healthcare professional.';
  }

  static String _heartGuidance(HealthChatContext c) {
    if (c.hrMax == null) {
      return 'I do not have heart-rate samples yet. Keep the wearable connected and make sure the optical sensor has firm wrist contact.';
    }
    if (c.hrMax! >= 180) {
      return 'That is a high sustained range. If this happened at rest or with symptoms, treat it seriously and seek medical advice.';
    }
    if (c.hrMedian != null && c.hrMedian! < 50) {
      return 'A low resting pulse can be normal for some people, but compare it with your baseline and symptoms.';
    }
    return 'Heart rate is interpreted with motion context: high while running is different from high while resting.';
  }

  static String _oxygenGuidance(HealthChatContext c) {
    if (c.spo2Min == null) {
      return 'SpO2 is not available yet. MAX30102 readings need good finger/wrist contact and a stable signal.';
    }
    if (c.spo2Min! <= 90) {
      return 'That oxygen value is below the safety threshold used by Pulse Edge. Recheck fit immediately and seek help if it persists.';
    }
    if (c.spo2Min! < 95) {
      return 'That is a little lower than the typical resting range. Check sensor contact and watch the trend.';
    }
    return 'Your available oxygen readings are in a typical range.';
  }

  static double? median(List<double> xs) {
    if (xs.isEmpty) return null;
    final sorted = [...xs]..sort();
    return sorted[sorted.length ~/ 2];
  }

  static double? mean(List<double> xs) {
    if (xs.isEmpty) return null;
    return xs.reduce((a, b) => a + b) / xs.length;
  }

  static double? minOrNull(List<double> xs) =>
      xs.isEmpty ? null : xs.reduce(math.min);
  static double? maxOrNull(List<double> xs) =>
      xs.isEmpty ? null : xs.reduce(math.max);
}

class HealthChatContext {
  const HealthChatContext({
    required this.sampleCount,
    this.hrMin,
    this.hrMedian,
    this.hrMax,
    this.spo2Min,
    this.spo2Mean,
    this.tempMean,
    this.tempMin,
    this.tempMax,
    this.motionMean,
    this.recentHighAlerts = 0,
    this.recentMediumAlerts = 0,
  });

  const HealthChatContext.empty()
    : sampleCount = 0,
      hrMin = null,
      hrMedian = null,
      hrMax = null,
      spo2Min = null,
      spo2Mean = null,
      tempMean = null,
      tempMin = null,
      tempMax = null,
      motionMean = null,
      recentHighAlerts = 0,
      recentMediumAlerts = 0;

  final int sampleCount;
  final double? hrMin;
  final double? hrMedian;
  final double? hrMax;
  final double? spo2Min;
  final double? spo2Mean;
  final double? tempMean;
  final double? tempMin;
  final double? tempMax;
  final double? motionMean;
  final int recentHighAlerts;
  final int recentMediumAlerts;

  String get statusLine {
    if (sampleCount == 0) {
      return 'I do not have enough wearable data yet.';
    }
    if (recentHighAlerts > 0) {
      return 'Your recent status needs attention because a high-severity alert was logged.';
    }
    if (spo2Min != null && spo2Min! <= 90) {
      return 'Your recent status needs attention because oxygen dipped below the safety threshold.';
    }
    if (hrMax != null && hrMax! >= 140 && (motionMean ?? 1) < 1.3) {
      return 'Your recent status is cautious: heart rate was high while motion was low.';
    }
    return 'Your recent wearable status looks mostly steady.';
  }

  String get shortSummary => sampleCount == 0
      ? 'No recent wearable samples are available yet.'
      : 'Recent data: HR ${_range(hrMin, hrMax, 'bpm')}; SpO2 ${_value(spo2Mean, '%')}; skin temp ${_value(tempMean, 'C')}; motion ${_value(motionMean, 'g')}.';

  String get compactBullets =>
      [hrLine, spo2Line, tempLine, motionLine, alertLine].join('\n');

  String get hrLine => hrMedian == null
      ? '- Heart rate: waiting for samples.'
      : '- Heart rate: ${hrMin!.toStringAsFixed(0)}-${hrMax!.toStringAsFixed(0)} bpm, median ${hrMedian!.toStringAsFixed(0)}.';

  String get spo2Line => spo2Mean == null
      ? '- SpO2: not available yet.'
      : '- SpO2: average ${spo2Mean!.toStringAsFixed(0)}%, lowest ${spo2Min!.toStringAsFixed(0)}%.';

  String get tempLine => tempMean == null
      ? '- Skin temperature: not available yet.'
      : '- Skin temperature: average ${tempMean!.toStringAsFixed(1)}C, range ${tempMin!.toStringAsFixed(1)}-${tempMax!.toStringAsFixed(1)}C.';

  String get motionLine => motionMean == null
      ? '- Motion: not available yet.'
      : '- Motion: average intensity ${motionMean!.toStringAsFixed(2)}g.';

  String get alertLine => recentHighAlerts == 0 && recentMediumAlerts == 0
      ? '- Alerts: no recent alerts.'
      : '- Alerts: $recentHighAlerts high and $recentMediumAlerts medium in the last 24h.';

  static String _range(double? lo, double? hi, String unit) {
    if (lo == null || hi == null) return 'waiting';
    return '${lo.toStringAsFixed(0)}-${hi.toStringAsFixed(0)} $unit';
  }

  static String _value(double? v, String unit) {
    if (v == null) return 'waiting';
    final digits = unit == 'C' || unit == 'g' ? 1 : 0;
    return '${v.toStringAsFixed(digits)}$unit';
  }
}
