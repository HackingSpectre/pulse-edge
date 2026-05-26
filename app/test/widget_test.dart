import 'package:flutter_test/flutter_test.dart';
import 'package:pulse_edge/core/alerts/alert_severity.dart';
import 'package:pulse_edge/core/llm/scripted_assistant.dart';
import 'package:pulse_edge/core/ml/feature_window.dart';

void main() {
  group('AlertSeverity', () {
    test('round-trips by code', () {
      for (final s in AlertSeverity.values) {
        expect(AlertSeverity.fromCode(s.code), equals(s));
      }
    });
  });

  group('FeatureWindow', () {
    test('toModelInput preserves the documented feature order', () {
      const w = FeatureWindow(
        tsMs: 0,
        windowS: 30,
        hrMean: 70,
        hrStd: 4,
        hrMin: 60,
        hrMax: 80,
        rmssd: 30,
        pnn50: 0.1,
        spo2Mean: 97,
        tempMean: 33.5,
        tempSlope: 0.01,
        accelMean: 1.0,
        accelStd: 0.2,
        activity: 1,
      );
      final v = w.toModelInput();
      // 12 features per ml/anomaly/feature_spec.json.
      expect(v, hasLength(12));
      expect(v[0], 70);
      expect(v.last, 1);
    });

    test('falls back to hrMean when SpO2 is null', () {
      const w = FeatureWindow(
        tsMs: 0,
        windowS: 30,
        hrMean: 65,
        hrStd: 2,
        hrMin: 60,
        hrMax: 70,
        rmssd: 25,
        pnn50: 0.05,
        spo2Mean: null,
        tempMean: 33.5,
        tempSlope: 0,
        accelMean: 1,
        accelStd: 0.1,
        activity: 0,
      );
      expect(w.toModelInput()[6], 65); // index 6 is spo2Mean
    });
  });

  group('ScriptedAssistant', () {
    test('uses live health context and user name in fallback responses', () {
      const ctx = HealthChatContext(
        profileName: 'Ada',
        username: 'ada',
        liveHr: 82,
        liveSpo2: 98,
        liveTemp: 36.4,
        liveActivity: 0,
        deviceState: 'connected',
        sampleCount: 3,
        hrMin: 78,
        hrMedian: 81,
        hrMax: 84,
        spo2Min: 97,
        spo2Mean: 98,
        tempMean: 36.3,
        tempMin: 36.1,
        tempMax: 36.5,
        motionMean: 1.0,
      );

      final reply = ScriptedAssistant.reply('How am I today?', context: ctx);

      expect(reply, contains('Ada'));
      expect(reply, contains('82 bpm'));
      expect(reply, contains('98%'));
    });
  });
}
