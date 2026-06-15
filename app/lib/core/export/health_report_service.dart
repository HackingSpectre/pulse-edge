import 'dart:convert';
import 'dart:io';

import 'package:intl/intl.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import '../alerts/alert_severity.dart';
import '../db/database.dart';
import '../db/repositories.dart';

class HealthReportService {
  HealthReportService({
    required SensorRepo sensorRepo,
    required FeatureRepo featureRepo,
    required AnomalyRepo anomalyRepo,
    required ProfileRepo profileRepo,
  }) : _sensorRepo = sensorRepo,
       _featureRepo = featureRepo,
       _anomalyRepo = anomalyRepo,
       _profileRepo = profileRepo;

  final SensorRepo _sensorRepo;
  final FeatureRepo _featureRepo;
  final AnomalyRepo _anomalyRepo;
  final ProfileRepo _profileRepo;

  Future<HealthReportBundle> createReport({
    required DateTime from,
    required DateTime to,
  }) async {
    final fromMs = from.millisecondsSinceEpoch;
    final toMs = to.millisecondsSinceEpoch;
    final profile = await _profileRepo.get();
    final ppg = await _sensorRepo.ppgInRange(fromMs, toMs);
    final temp = await _sensorRepo.tempInRange(fromMs, toMs);
    final imu = await _sensorRepo.imuInRange(fromMs, toMs);
    final features = await _featureRepo.inRange(fromMs, toMs);
    final anomalies = await _anomalyRepo.inRange(fromMs, toMs);

    final report = _HealthReport(
      profile: profile,
      from: from,
      to: to,
      ppg: ppg,
      temp: temp,
      imu: imu,
      features: features,
      anomalies: anomalies,
    );

    final generatedAt = DateTime.now();
    final stamp = DateFormat('yyyyMMdd_HHmm').format(generatedAt);
    final dir = await _reportDirectory();
    final summaryFile = File(p.join(dir.path, 'pulse_edge_report_$stamp.txt'));
    final csvFile = File(p.join(dir.path, 'pulse_edge_metrics_$stamp.csv'));

    await summaryFile.writeAsString(report.summaryText(generatedAt));
    await csvFile.writeAsString(report.metricsCsv());

    return HealthReportBundle(
      summaryFile: summaryFile,
      csvFile: csvFile,
      subject: report.emailSubject(),
      shareText: report.shareText(),
      hasData: report.hasData,
    );
  }

  Future<Directory> _reportDirectory() async {
    final base = await getApplicationDocumentsDirectory();
    final dir = Directory(p.join(base.path, 'reports'));
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }
    return dir;
  }
}

class HealthReportBundle {
  const HealthReportBundle({
    required this.summaryFile,
    required this.csvFile,
    required this.subject,
    required this.shareText,
    required this.hasData,
  });

  final File summaryFile;
  final File csvFile;
  final String subject;
  final String shareText;
  final bool hasData;

  List<File> get files => [summaryFile, csvFile];
}

class _HealthReport {
  const _HealthReport({
    required this.profile,
    required this.from,
    required this.to,
    required this.ppg,
    required this.temp,
    required this.imu,
    required this.features,
    required this.anomalies,
  });

  final Profile? profile;
  final DateTime from;
  final DateTime to;
  final List<PpgSample> ppg;
  final List<TempSample> temp;
  final List<ImuSample> imu;
  final List<FeatureRow> features;
  final List<AnomalyRow> anomalies;

  bool get hasData =>
      ppg.isNotEmpty ||
      temp.isNotEmpty ||
      imu.isNotEmpty ||
      features.isNotEmpty ||
      anomalies.isNotEmpty;

  String emailSubject() {
    final name = profile?.name.trim();
    final owner = name == null || name.isEmpty ? 'Pulse Edge user' : name;
    return 'Pulse Edge health summary - $owner';
  }

  String shareText() {
    final period = _periodLabel();
    return 'Pulse Edge health summary for $period. '
        'Attached are a readable summary and a detailed readings file.';
  }

  String summaryText(DateTime generatedAt) {
    final hr = _Stats.from(ppg.map((s) => s.hrBpm));
    final spo2 = _Stats.from(ppg.map((s) => s.spo2).whereType<double>());
    final skinTemp = _Stats.from(temp.map((s) => s.celsius));
    final rmssd = _Stats.from(features.map((f) => f.rmssd));
    final risk = _Stats.from(
      features.map((f) => f.anomalyP).whereType<double>(),
    );
    final activity = _activityBreakdown();
    final highAlerts = anomalies
        .where((a) => a.severity >= AlertSeverity.high.index)
        .length;
    final mediumAlerts = anomalies
        .where((a) => a.severity == AlertSeverity.medium.index)
        .length;

    final b = StringBuffer()
      ..writeln('PULSE EDGE HEALTH SUMMARY')
      ..writeln('Generated: ${_dt(generatedAt)}')
      ..writeln('Period: ${_periodLabel()}')
      ..writeln()
      ..writeln('PATIENT')
      ..writeln('Name: ${_profileName()}')
      ..writeln('Age: ${_ageLabel()}')
      ..writeln('Sex: ${_sexLabel()}')
      ..writeln('Height: ${_num(profile?.heightCm, 'cm')}')
      ..writeln('Weight: ${_num(profile?.weightKg, 'kg')}')
      ..writeln()
      ..writeln('HEALTH NOTE')
      ..writeln(
        'This report is generated from wearable readings stored by Pulse Edge. '
        'It is intended to support discussion with a healthcare professional '
        'and is not a diagnosis.',
      )
      ..writeln()
      ..writeln('DATA COVERAGE')
      ..writeln('Heart and blood oxygen samples: ${ppg.length}')
      ..writeln('Temperature samples: ${temp.length}')
      ..writeln('Motion samples: ${imu.length}')
      ..writeln('Reading windows: ${features.length}')
      ..writeln('Alerts in period: ${anomalies.length}')
      ..writeln()
      ..writeln('SUMMARY')
      ..writeln('Heart rate: ${hr.format(unit: 'bpm', decimals: 0)}')
      ..writeln('Blood oxygen: ${spo2.format(unit: '%', decimals: 1)}')
      ..writeln('Skin temperature: ${skinTemp.format(unit: 'C', decimals: 1)}')
      ..writeln(
        'Heart rhythm variation: ${rmssd.format(unit: 'ms', decimals: 1)}',
      )
      ..writeln('Pattern score: ${risk.format(unit: '', decimals: 2)}')
      ..writeln('Activity: $activity')
      ..writeln()
      ..writeln('READING PATTERN SUMMARY')
      ..writeln(_riskInterpretation(risk.mean))
      ..writeln(
        'Alert severity counts: $highAlerts high, $mediumAlerts medium, '
        '${anomalies.length - highAlerts - mediumAlerts} low.',
      )
      ..writeln()
      ..writeln('NOTABLE ALERTS');

    if (anomalies.isEmpty) {
      b.writeln('No alerts were recorded in this period.');
    } else {
      for (final a in anomalies.take(12)) {
        b
          ..writeln(
            '- ${_dt(DateTime.fromMillisecondsSinceEpoch(a.tsMs))} | '
            '${_severity(a.severity)} | ${a.type}',
          )
          ..writeln('  ${a.explanation ?? 'No explanation recorded.'}');
        final metrics = _metricsLine(a.metricsJson);
        if (metrics.isNotEmpty) b.writeln('  Metrics: $metrics');
      }
      if (anomalies.length > 12) {
        b.writeln(
          '- ${anomalies.length - 12} more alerts omitted from summary.',
        );
      }
    }

    b
      ..writeln()
      ..writeln('FILES')
      ..writeln(
        'The detailed readings file contains one row per reading window with '
        'heart, oxygen, temperature, movement, activity, and pattern fields.',
      );

    return b.toString();
  }

  String metricsCsv() {
    final b = StringBuffer()
      ..writeln(
        [
          'timestamp',
          'window_s',
          'hr_mean_bpm',
          'hr_std_bpm',
          'hr_min_bpm',
          'hr_max_bpm',
          'rmssd_ms',
          'pnn50',
          'spo2_mean_pct',
          'temp_mean_c',
          'temp_slope',
          'accel_mean',
          'accel_std',
          'activity',
          'pattern_score',
        ].join(','),
      );

    for (final f in features) {
      b.writeln(
        [
          _dt(DateTime.fromMillisecondsSinceEpoch(f.tsMs)),
          f.windowS,
          _fixed(f.hrMean, 2),
          _fixed(f.hrStd, 2),
          _fixed(f.hrMin, 2),
          _fixed(f.hrMax, 2),
          _fixed(f.rmssd, 2),
          _fixed(f.pnn50, 4),
          _fixedOrBlank(f.spo2Mean, 2),
          _fixed(f.tempMean, 2),
          _fixed(f.tempSlope, 5),
          _fixed(f.accelMean, 4),
          _fixed(f.accelStd, 4),
          ActivityClass.name(f.activity),
          _fixedOrBlank(f.anomalyP, 4),
        ].map(_csv).join(','),
      );
    }

    return b.toString();
  }

  String _periodLabel() {
    final fmt = DateFormat.yMMMd().add_jm();
    return '${fmt.format(from)} to ${fmt.format(to)}';
  }

  String _profileName() {
    final name = profile?.name.trim();
    if (name == null || name.isEmpty) return 'Not set';
    return name;
  }

  String _ageLabel() {
    final birthYear = profile?.birthYear;
    if (birthYear == null || birthYear <= 1900) return 'Not set';
    return '${DateTime.now().year - birthYear} years';
  }

  String _sexLabel() {
    return switch (profile?.sex) {
      1 => 'Male',
      2 => 'Female',
      3 => 'Other',
      _ => 'Not specified',
    };
  }

  String _num(double? v, String unit) =>
      v == null ? 'Not set' : '${v.toStringAsFixed(1)} $unit';

  String _activityBreakdown() {
    if (features.isEmpty) return 'No activity windows';
    final counts = <int, int>{};
    for (final f in features) {
      counts[f.activity] = (counts[f.activity] ?? 0) + 1;
    }
    final total = features.length;
    final parts = counts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    return parts
        .map((e) {
          final pct = e.value * 100 / total;
          return '${ActivityClass.name(e.key)} ${pct.toStringAsFixed(0)}%';
        })
        .join(', ');
  }

  String _riskInterpretation(double? meanRisk) {
    if (features.isEmpty || meanRisk == null) {
      return 'No reading windows were available for pattern review.';
    }
    final highWindows = features.where((f) => (f.anomalyP ?? 0) >= 0.75).length;
    final elevatedWindows = features
        .where((f) => (f.anomalyP ?? 0) >= 0.50)
        .length;
    if (highWindows > 0) {
      return 'Pulse Edge recorded $highWindows higher-risk windows and '
          '$elevatedWindows elevated windows. Review the alert timeline and '
          'compare readings with symptoms, activity, medication, and context.';
    }
    if (elevatedWindows > 0) {
      return 'Pulse Edge recorded $elevatedWindows elevated-risk windows, but '
          'no high-risk windows. These may reflect stress, activity, sensor '
          'contact, or true physiological change.';
    }
    return 'Pulse Edge did not record elevated-risk reading windows in this period.';
  }

  String _metricsLine(String jsonText) {
    try {
      final decoded = jsonDecode(jsonText);
      if (decoded is! Map<String, dynamic>) return '';
      return decoded.entries
          .take(6)
          .map((e) => '${e.key}=${e.value}')
          .join(', ');
    } catch (_) {
      return '';
    }
  }

  String _severity(int value) {
    return switch (value) {
      2 => 'HIGH',
      1 => 'MEDIUM',
      _ => 'LOW',
    };
  }
}

class _Stats {
  const _Stats({
    required this.count,
    required this.mean,
    required this.min,
    required this.max,
    required this.p10,
    required this.p90,
  });

  final int count;
  final double? mean;
  final double? min;
  final double? max;
  final double? p10;
  final double? p90;

  factory _Stats.from(Iterable<double> values) {
    final sorted = values.where((v) => v.isFinite).toList()..sort();
    if (sorted.isEmpty) {
      return const _Stats(
        count: 0,
        mean: null,
        min: null,
        max: null,
        p10: null,
        p90: null,
      );
    }
    final mean = sorted.reduce((a, b) => a + b) / sorted.length;
    return _Stats(
      count: sorted.length,
      mean: mean,
      min: sorted.first,
      max: sorted.last,
      p10: sorted[_percentileIndex(sorted.length, 0.10)],
      p90: sorted[_percentileIndex(sorted.length, 0.90)],
    );
  }

  String format({required String unit, required int decimals}) {
    if (count == 0 || mean == null || min == null || max == null) {
      return 'No data';
    }
    final suffix = unit.isEmpty ? '' : ' $unit';
    return 'average ${mean!.toStringAsFixed(decimals)}$suffix, '
        'range ${min!.toStringAsFixed(decimals)}-'
        '${max!.toStringAsFixed(decimals)}$suffix, '
        'lower/upper typical range ${p10!.toStringAsFixed(decimals)}/'
        '${p90!.toStringAsFixed(decimals)}$suffix (n=$count)';
  }

  static int _percentileIndex(int length, double p) {
    return ((length - 1) * p).round().clamp(0, length - 1);
  }
}

String _dt(DateTime value) => DateFormat('yyyy-MM-dd HH:mm').format(value);

String _fixed(double value, int decimals) => value.toStringAsFixed(decimals);

String _fixedOrBlank(double? value, int decimals) =>
    value == null ? '' : value.toStringAsFixed(decimals);

String _csv(Object? value) {
  final s = '${value ?? ''}';
  if (!s.contains(',') && !s.contains('"') && !s.contains('\n')) return s;
  return '"${s.replaceAll('"', '""')}"';
}
