import 'dart:convert';
import 'dart:math' as math;

/// Deterministic local assistant used instead of a downloaded LLM.
///
/// This is not a diagnosis engine. It is a compact rule-based explainer that
/// grounds answers in the user's recent local wearable data.
class ScriptedAssistant {
  static const String disclaimer =
      '\n\nPulse Edge is not a medical device and cannot diagnose or treat any '
      'condition. If you feel unwell or readings remain unusual, contact a '
      'healthcare professional.';

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
      'severe pain',
      'confused',
      'blue lips',
      'collapse',
      'collapsed',
    ])) {
      return '${_lead(hello, 'those symptoms can be urgent.')} Pulse Edge cannot diagnose you. Stop activity, sit or lie down, and get medical help now if symptoms are severe, new, or worsening.\n\n${ctx.shortSummary}';
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

    if (_any(m, ['hrv', 'rmssd', 'recovery', 'stress', 'calm'])) {
      return '${_lead(hello, 'HRV is a trend signal, not a diagnosis.')} Lower HRV can happen with stress, poor sleep, illness, dehydration, or hard exercise. Pulse Edge uses HRV together with heart rate, oxygen, temperature, and motion before raising concern.';
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
      return 'Pulse Edge explains your readings on this phone, using your recent wearable data and safety-focused guidance.';
    }

    if (_any(m, ['privacy', 'cloud', 'internet', 'server'])) {
      return 'Pulse Edge is designed offline-first. Your sensor history, usual-pattern learning, alerts, reports, and assistant replies stay on your phone.';
    }

    if (_any(m, ['what should i do', 'advice', 'help me', 'recommend'])) {
      return '${_lead(hello, _nextStep(ctx))}\n\n${ctx.compactBullets}';
    }

    return '${_lead(hello, 'I can help with heart rate, blood oxygen, skin temperature, movement, alerts, privacy, and today\'s health status.')}\n\n${ctx.shortSummary}';
  }

  static String dailySummary(HealthChatContext c) {
    if (c.sampleCount == 0) {
      return 'Today: I do not have enough stored wearable samples yet. Keep the device connected for a few minutes, then ask again.';
    }
    return 'Today: ${c.statusLine}\n\n${c.compactBullets}\n\n${_nextStep(c)}';
  }

  static String explainAnomaly({
    required String type,
    required String metricsJson,
  }) {
    final metrics = _parseMetrics(metricsJson);
    final hr = _metric(metrics, 'hrMean');
    final spo2 = _metric(metrics, 'spo2');
    final temp = _metric(metrics, 'tempMean');
    final modelP = _metric(metrics, 'modelP');
    final activity = _activityFromMetrics(metrics);
    final context = [
      if (hr != null) 'heart rate ${hr.toStringAsFixed(0)} bpm',
      if (spo2 != null) 'blood oxygen ${spo2.toStringAsFixed(0)}%',
      if (temp != null) 'skin temp ${temp.toStringAsFixed(1)}C',
      if (activity != null) 'activity $activity',
      if (modelP != null) 'pattern score ${modelP.toStringAsFixed(2)}',
    ].join(', ');

    final base = switch (type) {
      'tachycardia' =>
        'Pulse Edge flagged sustained high heart rate. Rest and recheck sensor fit.',
      'bradycardia' =>
        'Pulse Edge flagged sustained low heart rate. Compare with your normal resting range.',
      'hypoxia' =>
        'Pulse Edge flagged low oxygen saturation. Recheck contact immediately and watch whether it recovers.',
      'hyperthermia' =>
        'Pulse Edge flagged high skin temperature. Cool down, hydrate, and compare with how you feel.',
      'hypothermia' =>
        'Pulse Edge flagged low skin temperature. Warm up and confirm the wearable has good skin contact.',
      'fall' =>
        'Pulse Edge flagged a motion pattern that may fit a fall. Check your body and surroundings.',
      _ =>
        'Pulse Edge flagged a pattern that was unusual against its rule set and your recent context.',
    };
    return context.isEmpty ? base : '$base Recorded context: $context.';
  }

  static bool _any(String text, List<String> terms) => terms.any(text.contains);
  static String _lead(String prefix, String text) =>
      prefix.isEmpty ? text : '$prefix $text';

  static String _nextStep(HealthChatContext c) {
    if (c.recentHighAlerts > 0 || c.spo2Min != null && c.spo2Min! <= 90) {
      return 'Next step: sit down, re-check the wearable fit, and get medical help if you feel unwell or the reading persists.';
    }
    if (c.sensorOk == false || c.contactOk == false) {
      return 'Next step: fix wearable contact first, then wait for a stable 30-second window before trusting the trend.';
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
    if (c.hrMax! >= 140 && (c.motionMean ?? 1.0) < 1.25) {
      return 'Heart rate was high while motion looked low. Rest, recheck fit, and watch whether it returns toward your usual range.';
    }
    if (c.hrMedian != null && c.hrMedian! < 50) {
      return 'A low resting pulse can be normal for some people, but compare it with your usual range and symptoms.';
    }
    return 'Heart rate is interpreted with motion context: high while running is different from high while resting.';
  }

  static String _oxygenGuidance(HealthChatContext c) {
    if (c.spo2Min == null) {
      return 'Blood oxygen is not available yet. The sensor needs good skin contact and a stable signal.';
    }
    if (c.spo2Min! <= 90) {
      return 'That oxygen value is below the safety level used by Pulse Edge. Recheck fit immediately and seek help if it persists.';
    }
    if (c.spo2Min! < 95) {
      return 'That is a little lower than the typical resting range. Check sensor contact and watch the trend.';
    }
    return 'Your available oxygen readings are in a typical range.';
  }

  static Map<String, dynamic> _parseMetrics(String jsonText) {
    try {
      final value = jsonDecode(jsonText);
      if (value is Map<String, dynamic>) return value;
    } catch (_) {}
    return const {};
  }

  static double? _metric(Map<String, dynamic> metrics, String key) {
    final value = metrics[key];
    if (value is num && value.isFinite) return value.toDouble();
    return null;
  }

  static String? _activityFromMetrics(Map<String, dynamic> metrics) {
    final value = metrics['activity'];
    if (value is int) return ActivityClassName.name(value);
    if (value is num) return ActivityClassName.name(value.toInt());
    return null;
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
    this.recentLowAlerts = 0,
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
      recentMediumAlerts = 0,
      recentLowAlerts = 0;

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
  final int recentLowAlerts;

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
      return 'Your recent status needs attention because oxygen dipped below the safety level.';
    }
    if (hrMax != null && hrMax! >= 140 && (motionMean ?? 1) < 1.3) {
      return 'Your recent status is cautious: heart rate was high while motion was low.';
    }
    return 'Your recent wearable status looks mostly steady.';
  }

  String get shortSummary => sampleCount == 0
      ? 'Current data: $liveSnapshot. No stored wearable samples are available yet.'
      : 'Current data: $liveSnapshot. Recent data: heart rate ${_range(hrMin, hrMax, 'bpm')}; blood oxygen ${_value(spo2Mean, '%')}; skin temp ${_value(tempMean, 'C')}; movement ${_value(motionMean, 'g')}.';

  String get compactBullets =>
      [hrLine, spo2Line, tempLine, motionLine, alertLine].join('\n');

  String get hrLine => hrMedian == null
      ? '- Heart rate: ${liveHr == null ? 'waiting for samples' : '${liveHr!.toStringAsFixed(0)} bpm live'}.'
      : '- Heart rate: ${liveHr == null ? '' : '${liveHr!.toStringAsFixed(0)} bpm live; '}${hrMin!.toStringAsFixed(0)}-${hrMax!.toStringAsFixed(0)} bpm recent range, median ${hrMedian!.toStringAsFixed(0)}.';

  String get spo2Line => spo2Mean == null
      ? '- Blood oxygen: ${liveSpo2 == null ? 'not available yet' : '${liveSpo2!.toStringAsFixed(0)}% live'}.'
      : '- Blood oxygen: ${liveSpo2 == null ? '' : '${liveSpo2!.toStringAsFixed(0)}% live; '}average ${spo2Mean!.toStringAsFixed(0)}%, lowest ${spo2Min!.toStringAsFixed(0)}%.';

  String get tempLine => tempMean == null
      ? '- Skin temperature: ${liveTemp == null ? 'not available yet' : '${liveTemp!.toStringAsFixed(1)}C live'}.'
      : '- Skin temperature: ${liveTemp == null ? '' : '${liveTemp!.toStringAsFixed(1)}C live; '}average ${tempMean!.toStringAsFixed(1)}C, range ${tempMin!.toStringAsFixed(1)}-${tempMax!.toStringAsFixed(1)}C.';

  String get motionLine => motionMean == null
      ? '- Movement: ${liveMotion == null ? ActivityClassName.name(liveActivity) : '${liveMotion!.toStringAsFixed(2)}g live'}.'
      : '- Movement: ${liveMotion == null ? '' : '${liveMotion!.toStringAsFixed(2)}g live; '}average intensity ${motionMean!.toStringAsFixed(2)}g.';

  String get alertLine => recentHighAlerts == 0 && recentMediumAlerts == 0
      ? recentLowAlerts == 0
            ? '- Alerts: no recent alerts.'
            : '- Alerts: $recentLowAlerts low-priority note${recentLowAlerts == 1 ? '' : 's'} in the last 24h.'
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
      'heart rate ${liveHr == null ? 'waiting' : '${liveHr!.toStringAsFixed(0)} bpm'}',
      'blood oxygen ${liveSpo2 == null ? 'waiting' : '${liveSpo2!.toStringAsFixed(0)}%'}',
      'skin temp ${liveTemp == null ? 'waiting' : '${liveTemp!.toStringAsFixed(1)}C'}',
      'activity ${ActivityClassName.name(liveActivity)}',
      if (contactOk == false) 'contact weak',
      if (sensorOk == false) 'sensor issue',
    ];
    return parts.join(', ');
  }

  String? get _liveConcern {
    if (liveSpo2 != null && liveSpo2! <= 90) {
      return 'your live oxygen reading is below the app safety level.';
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
