import 'dart:math' as math;

/// Deterministic fallback used when the offline edge model is not installed.
///
/// This is not a diagnosis engine. It is a compact rule-based explainer that
/// grounds answers in the user's recent local wearable data.
class ScriptedAssistant {
  static String reply(String userMessage, {HealthChatContext? context}) {
    final m = userMessage.toLowerCase();
    final ctx = context ?? const HealthChatContext.empty();
    final hello = ctx.greetingPrefix;

    if (_any(m, [
      'chest pain',
      'faint',
      'fainted',
      'can\'t breathe',
      'cant breathe',
      'shortness of breath',
    ])) {
      return '${_lead(hello, 'those symptoms can be urgent.')} Pulse Edge cannot diagnose you, but you should get medical help now if symptoms are severe, new, or worsening.\n\n${ctx.shortSummary}';
    }

    if (_any(m, [
      'how am i',
      'health status',
      'status',
      'am i okay',
      'today',
      'summary',
    ])) {
      return '${_lead(hello, ctx.statusLine)}\n\n${ctx.compactBullets}\n\n${_nextStep(ctx)}';
    }

    if (_any(m, ['heart', 'hr', 'bpm', 'pulse', 'tachy', 'brady'])) {
      return '${_lead(hello, ctx.hrLine)}\n\n${_heartGuidance(ctx)}';
    }

    if (_any(m, ['oxygen', 'spo2', 'sp02', 'breath', 'hypoxia'])) {
      return '${_lead(hello, ctx.spo2Line)}\n\n${_oxygenGuidance(ctx)}';
    }

    if (_any(m, ['temperature', 'temp', 'fever', 'hot', 'cold'])) {
      return '${_lead(hello, ctx.tempLine)}\n\nSkin temperature is best used as a trend, because a wrist sensor usually reads lower than core body temperature.';
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
      return '${_lead(hello, ctx.motionLine)}\n\nMotion helps Pulse Edge decide whether a high heart rate looks activity-related or unusual for rest.';
    }

    if (_any(m, ['alert', 'anomaly', 'warning', 'notification'])) {
      return '${_lead(hello, ctx.alertLine)}\n\nAlerts are based on sustained windows, not single noisy samples. Open the Alerts tab for the exact metrics and explanation.';
    }

    if (_any(m, ['model', 'download', 'ai assistant', 'offline'])) {
      return 'You are using the rule-based assistant right now. It analyzes your current wearable data with local rules. Download the offline edge model for fuller conversation while keeping responses on this phone.';
    }

    if (_any(m, ['privacy', 'cloud', 'internet', 'server'])) {
      return 'Pulse Edge is designed offline-first. Sensor history, baseline learning, alerts, and this fallback assistant run on your phone. Internet is only needed if you choose to download the local AI model.';
    }

    if (_any(m, ['what should i do', 'advice', 'help me', 'recommend'])) {
      return '${_lead(hello, _nextStep(ctx))}\n\n${ctx.compactBullets}';
    }

    return '${_lead(hello, 'I can help with heart rate, SpO2, skin temperature, motion, alerts, privacy, and today\'s health status.')}\n\n${ctx.shortSummary}';
  }

  static bool _any(String text, List<String> terms) => terms.any(text.contains);
  static String _lead(String prefix, String text) =>
      prefix.isEmpty ? text : '$prefix $text';

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
    this.profileName,
    this.username,
    this.liveHr,
    this.liveSpo2,
    this.liveTemp,
    this.liveActivity = 0,
    this.liveMotion,
    this.deviceState,
    this.deviceName,
    this.contactOk,
    this.sensorOk,
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
    : profileName = null,
      username = null,
      liveHr = null,
      liveSpo2 = null,
      liveTemp = null,
      liveActivity = 0,
      liveMotion = null,
      deviceState = null,
      deviceName = null,
      contactOk = null,
      sensorOk = null,
      sampleCount = 0,
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

  final String? profileName;
  final String? username;
  final double? liveHr;
  final double? liveSpo2;
  final double? liveTemp;
  final int liveActivity;
  final double? liveMotion;
  final String? deviceState;
  final String? deviceName;
  final bool? contactOk;
  final bool? sensorOk;
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

  String get greetingPrefix {
    final name = profileName?.trim();
    if (name == null || name.isEmpty || name == 'Friend') return '';
    return '$name,';
  }

  String get statusLine {
    if (sensorOk == false) {
      return 'your wearable is reporting a sensor issue, so readings may be less reliable.';
    }
    if (contactOk == false) {
      return 'your wearable contact looks weak right now, so adjust the fit before trusting the trend.';
    }
    if (liveHr != null || liveSpo2 != null || liveTemp != null) {
      final liveConcern = _liveConcern;
      if (liveConcern != null) return liveConcern;
      return 'your live readings look steady right now.';
    }
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
      ? 'Current data: $liveSnapshot. No stored wearable samples are available yet.'
      : 'Current data: $liveSnapshot. Recent data: HR ${_range(hrMin, hrMax, 'bpm')}; SpO2 ${_value(spo2Mean, '%')}; skin temp ${_value(tempMean, 'C')}; motion ${_value(motionMean, 'g')}.';

  String get compactBullets =>
      [hrLine, spo2Line, tempLine, motionLine, alertLine].join('\n');

  String get hrLine => hrMedian == null
      ? '- Heart rate: ${liveHr == null ? 'waiting for samples' : '${liveHr!.toStringAsFixed(0)} bpm live'}.'
      : '- Heart rate: ${liveHr == null ? '' : '${liveHr!.toStringAsFixed(0)} bpm live; '}${hrMin!.toStringAsFixed(0)}-${hrMax!.toStringAsFixed(0)} bpm recent range, median ${hrMedian!.toStringAsFixed(0)}.';

  String get spo2Line => spo2Mean == null
      ? '- SpO2: ${liveSpo2 == null ? 'not available yet' : '${liveSpo2!.toStringAsFixed(0)}% live'}.'
      : '- SpO2: ${liveSpo2 == null ? '' : '${liveSpo2!.toStringAsFixed(0)}% live; '}average ${spo2Mean!.toStringAsFixed(0)}%, lowest ${spo2Min!.toStringAsFixed(0)}%.';

  String get tempLine => tempMean == null
      ? '- Skin temperature: ${liveTemp == null ? 'not available yet' : '${liveTemp!.toStringAsFixed(1)}C live'}.'
      : '- Skin temperature: ${liveTemp == null ? '' : '${liveTemp!.toStringAsFixed(1)}C live; '}average ${tempMean!.toStringAsFixed(1)}C, range ${tempMin!.toStringAsFixed(1)}-${tempMax!.toStringAsFixed(1)}C.';

  String get motionLine => motionMean == null
      ? '- Motion: ${liveMotion == null ? ActivityClassName.name(liveActivity) : '${liveMotion!.toStringAsFixed(2)}g live'}.'
      : '- Motion: ${liveMotion == null ? '' : '${liveMotion!.toStringAsFixed(2)}g live; '}average intensity ${motionMean!.toStringAsFixed(2)}g.';

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

  String get liveSnapshot {
    final parts = <String>[
      if (deviceName != null) 'device $deviceName',
      if (deviceState != null) 'state $deviceState',
      'HR ${liveHr == null ? 'waiting' : '${liveHr!.toStringAsFixed(0)} bpm'}',
      'SpO2 ${liveSpo2 == null ? 'waiting' : '${liveSpo2!.toStringAsFixed(0)}%'}',
      'skin temp ${liveTemp == null ? 'waiting' : '${liveTemp!.toStringAsFixed(1)}C'}',
      'activity ${ActivityClassName.name(liveActivity)}',
      if (contactOk == false) 'contact weak',
      if (sensorOk == false) 'sensor issue',
    ];
    return parts.join(', ');
  }

  String? get _liveConcern {
    if (liveSpo2 != null && liveSpo2! <= 90) {
      return 'your live oxygen reading is below the app safety threshold.';
    }
    if (liveHr != null && liveHr! >= 180) {
      return 'your live heart rate is very high right now.';
    }
    if (liveHr != null && liveHr! <= 35) {
      return 'your live heart rate is very low right now.';
    }
    if (liveTemp != null && liveTemp! >= 39.5) {
      return 'your live skin temperature is high right now.';
    }
    if (liveTemp != null && liveTemp! <= 34) {
      return 'your live skin temperature is low right now.';
    }
    return null;
  }

  String toPromptContext() {
    return [
      'User name: ${profileName ?? 'not set'}',
      'Username: ${username == null ? 'not set' : '@$username'}',
      'Live snapshot: $liveSnapshot',
      'Recent summary: $shortSummary',
      'Alerts: $alertLine',
    ].join('\n');
  }
}

class ActivityClassName {
  static String name(int a) =>
      const ['resting', 'walking', 'running', 'other'][a.clamp(0, 3)];
}
