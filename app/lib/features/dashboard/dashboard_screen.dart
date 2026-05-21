import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:rxdart/rxdart.dart';

import '../../app/router.dart';
import '../../core/ble/connection_state.dart';
import '../../core/ble/sensor_packet.dart';
import '../../core/db/database.dart';
import '../../core/health/health_analyzer.dart';
import '../../core/providers.dart';
import '../../core/theme/tokens.dart';
import '../../shared/widgets/widgets.dart';

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  @override
  void initState() {
    super.initState();
    // Auto-start the demo source if no real connection is up. Lets first-launch
    // users see the dashboard come alive immediately, even after a scan error.
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final ble = ref.read(bleServiceProvider);
      if (ble.status.state == BleConnState.idle ||
          ble.status.state == BleConnState.error) {
        await ble.startDemo();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final ble = ref.watch(bleServiceProvider);
    return NeuScaffold(
      title: 'Live',
      actions: [
        NeuIconButton(
          icon: Icons.refresh_rounded,
          tooltip: 'Reconnect',
          onPressed: () => ble.startDemo(),
        ),
      ],
      scrollable: true,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _ConnectionStrip(),
          const SizedBox(height: T.space5),
          _HealthStatusCard(),
          const SizedBox(height: T.space5),
          _HrHero(),
          const SizedBox(height: T.space5),
          _WearableMetrics(),
          const SizedBox(height: T.space5),
          _LiveSparkline(),
          const SizedBox(height: T.space5),
          _DailySummaryCard(),
        ],
      ),
    );
  }
}

class _ConnectionStrip extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ble = ref.watch(bleServiceProvider);
    return StreamBuilder<BleStatus>(
      stream: ble.status$,
      initialData: ble.status,
      builder: (context, snap) {
        final s = snap.data ?? BleStatus.idle;
        final color = switch (s.state) {
          BleConnState.connected =>
            s.contactOk == false || s.sensorOk == false ? T.warning : T.success,
          BleConnState.connecting || BleConnState.reconnecting => T.warning,
          BleConnState.error => T.danger,
          _ => T.inkMuted,
        };
        final label = switch (s.state) {
          BleConnState.connected =>
            s.contactOk == false
                ? 'Adjust wearable contact'
                : (s.demo ? 'Demo data' : (s.deviceName ?? 'Connected')),
          BleConnState.connecting => 'Connecting…',
          BleConnState.reconnecting => 'Reconnecting…',
          BleConnState.scanning => 'Scanning…',
          BleConnState.error => 'Connection error',
          _ => 'Not connected',
        };
        return NeuCard(
          padding: const EdgeInsets.symmetric(
            horizontal: T.space4,
            vertical: T.space3,
          ),
          child: Row(
            children: [
              Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: color.withValues(alpha: 0.5),
                      blurRadius: 6,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: T.space3),
              Expanded(child: Text(label, style: T.bodyStrong)),
              if (s.batteryPct != null) ...[
                const Icon(
                  Icons.battery_full_rounded,
                  size: T.iconSm,
                  color: T.inkSoft,
                ),
                const SizedBox(width: 4),
                Text('${s.batteryPct}%', style: T.caption),
              ],
            ],
          ),
        );
      },
    );
  }
}

class _HrHero extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ble = ref.watch(bleServiceProvider);
    return Center(
      child: StreamBuilder<double?>(
        stream: ble.hr$,
        builder: (context, snap) {
          final hr = snap.data;
          // Map 40..200 bpm onto the ring.
          final fill = ((hr ?? 60) - 40).clamp(0, 160) / 160;
          return NeuMetricRing(
            value: hr == null ? '--' : hr.toStringAsFixed(0),
            label: 'Heart rate',
            unit: 'bpm',
            fill: fill.toDouble(),
            subtitle: hr == null
                ? Text('Waiting for data', style: T.caption)
                : Text(_zone(hr), style: T.caption.copyWith(color: T.inkMuted)),
          );
        },
      ),
    );
  }

  String _zone(double hr) {
    if (hr < 50) return 'Low';
    if (hr < 90) return 'Resting';
    if (hr < 130) return 'Active';
    if (hr < 165) return 'Vigorous';
    return 'High';
  }
}

class _WearableMetrics extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return StreamBuilder<_LiveVitals>(
      stream: _liveVitals(ref),
      builder: (context, snap) {
        final v = snap.data ?? const _LiveVitals();
        final motion = v.imu?.magnitudeMean;
        final accel = v.imu == null
            ? '--'
            : '${v.imu!.ax.toStringAsFixed(1)}, ${v.imu!.ay.toStringAsFixed(1)}, ${v.imu!.az.toStringAsFixed(1)}';
        final gyro = v.imu == null
            ? '--'
            : '${v.imu!.gx.toStringAsFixed(0)}, ${v.imu!.gy.toStringAsFixed(0)}, ${v.imu!.gz.toStringAsFixed(0)}';
        return GridView.count(
          crossAxisCount: 2,
          mainAxisSpacing: T.space3,
          crossAxisSpacing: T.space3,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          childAspectRatio: 1.18,
          children: [
            _MetricTile(
              icon: Icons.water_drop_rounded,
              color: T.info,
              label: 'SpO₂',
              value: v.spo2 == null ? '--' : v.spo2!.toStringAsFixed(0),
              unit: '%',
              caption: _oxygenLabel(v.spo2),
            ),
            _MetricTile(
              icon: Icons.thermostat_rounded,
              color: T.warning,
              label: 'Skin temp',
              value: v.temp == null ? '--' : v.temp!.toStringAsFixed(1),
              unit: '°C',
              caption: _tempLabel(v.temp),
            ),
            _MetricTile(
              icon: Icons.speed_rounded,
              color: T.primary,
              label: 'Motion',
              value: motion == null ? '--' : motion.toStringAsFixed(2),
              unit: 'g',
              caption: ActivityClass.name(v.activity),
            ),
            _MetricTile(
              icon: Icons.threed_rotation_rounded,
              color: T.danger,
              label: 'Gyro',
              value: gyro,
              unit: 'dps',
              compact: true,
              caption: 'x, y, z',
            ),
            _MetricTile(
              icon: Icons.open_with_rounded,
              color: T.success,
              label: 'Accel',
              value: accel,
              unit: 'm/s²',
              compact: true,
              caption: 'x, y, z',
            ),
            _MetricTile(
              icon: Icons.directions_walk_rounded,
              color: T.inkSoft,
              label: 'Activity',
              value: ActivityClass.name(v.activity),
              unit: '',
              compact: true,
              caption: _activityHint(v.activity),
            ),
          ],
        );
      },
    );
  }

  String _oxygenLabel(double? v) {
    if (v == null) return 'waiting';
    if (v < 90) return 'low';
    if (v < 95) return 'watch';
    return 'normal';
  }

  String _tempLabel(double? v) {
    if (v == null) return 'waiting';
    if (v >= 37.5) return 'warm';
    if (v < 35) return 'cool';
    return 'steady';
  }

  String _activityHint(int a) => switch (a) {
    0 => 'low motion',
    1 => 'light motion',
    2 => 'high motion',
    _ => 'mixed',
  };
}

class _MetricTile extends StatelessWidget {
  const _MetricTile({
    required this.icon,
    required this.color,
    required this.label,
    required this.value,
    required this.unit,
    this.caption,
    this.compact = false,
  });

  final IconData icon;
  final Color color;
  final String label;
  final String value;
  final String unit;
  final String? caption;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return NeuCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: T.iconSm, color: color),
              const SizedBox(width: T.space2),
              Text(label.toUpperCase(), style: T.label),
            ],
          ),
          const SizedBox(height: T.space3),
          FittedBox(
            alignment: Alignment.centerLeft,
            fit: BoxFit.scaleDown,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Text(value, style: compact ? T.metricSmall : T.metricLarge),
                if (unit.isNotEmpty) ...[
                  const SizedBox(width: 4),
                  Text(unit, style: T.label.copyWith(color: T.inkMuted)),
                ],
              ],
            ),
          ),
          if (caption != null) ...[
            const SizedBox(height: T.space2),
            Text(
              caption!,
              style: T.caption,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ],
      ),
    );
  }
}

class _HealthStatusCard extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final alerts = ref.watch(anomalyRepoProvider);
    return StreamBuilder<_LiveVitals>(
      stream: _liveVitals(ref),
      builder: (context, vitalsSnap) {
        return StreamBuilder<List<AnomalyRow>>(
          stream: alerts.watchAll(limit: 20),
          builder: (context, alertSnap) {
            final v = vitalsSnap.data ?? const _LiveVitals();
            final now = DateTime.now().millisecondsSinceEpoch;
            final recent = (alertSnap.data ?? const <AnomalyRow>[])
                .where((a) => now - a.tsMs <= 60 * 60 * 1000)
                .toList();
            final assessment = HealthAnalyzer.assessLatest(
              hr: v.hr,
              spo2: v.spo2,
              temp: v.temp,
              activity: v.activity,
              motion: v.imu?.magnitudeMean,
              sensorOk: v.status?.sensorOk,
              contactOk: v.status?.contactOk,
              recentHighAlerts: recent.where((a) => a.severity == 2).length,
              recentMediumAlerts: recent.where((a) => a.severity == 1).length,
            );
            return NeuCard(
              color: assessment.level.color.withValues(alpha: 0.10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: assessment.level.color.withValues(alpha: 0.14),
                          borderRadius: T.brSm,
                        ),
                        child: Icon(
                          _healthIcon(assessment.level),
                          color: assessment.level.color,
                          size: T.iconMd,
                        ),
                      ),
                      const SizedBox(width: T.space3),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Health status'.toUpperCase(), style: T.label),
                            const SizedBox(height: 2),
                            Text(assessment.title, style: T.h3),
                          ],
                        ),
                      ),
                      Text(
                        '${assessment.score}',
                        style: T.metricSmall.copyWith(
                          color: assessment.level.color,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: T.space3),
                  NeuLinearProgress(
                    value: assessment.score / 100,
                    color: assessment.level.color,
                    height: 8,
                  ),
                  const SizedBox(height: T.space3),
                  Text(assessment.summary, style: T.bodySoft),
                  const SizedBox(height: T.space2),
                  for (final reason in assessment.reasons)
                    Padding(
                      padding: const EdgeInsets.only(top: 3),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '- ',
                            style: T.caption.copyWith(
                              color: assessment.level.color,
                            ),
                          ),
                          Expanded(child: Text(reason, style: T.caption)),
                        ],
                      ),
                    ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  IconData _healthIcon(HealthLevel level) => switch (level) {
    HealthLevel.stable => Icons.verified_rounded,
    HealthLevel.watch => Icons.visibility_rounded,
    HealthLevel.caution => Icons.warning_amber_rounded,
    HealthLevel.attention => Icons.emergency_rounded,
  };
}

class _LiveSparkline extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final repo = ref.watch(sensorRepoProvider);
    return NeuCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text('Last 60 seconds'.toUpperCase(), style: T.label),
              const Spacer(),
              Text('HR', style: T.caption.copyWith(color: T.inkMuted)),
            ],
          ),
          const SizedBox(height: T.space3),
          SizedBox(
            height: 120,
            child: StreamBuilder<List<PpgSample>>(
              stream: repo.watchRecentPpg(),
              builder: (context, snap) {
                final samples = snap.data ?? const [];
                if (samples.isEmpty) {
                  return Center(
                    child: Text(
                      'Collecting…',
                      style: T.caption.copyWith(color: T.inkMuted),
                    ),
                  );
                }
                final spots = <FlSpot>[
                  for (var i = 0; i < samples.length; i++)
                    FlSpot(i.toDouble(), samples[i].hrBpm),
                ];
                final ys = spots.map((s) => s.y).toList()..sort();
                final loY = (ys.first - 6).floorToDouble();
                final hiY = (ys.last + 6).ceilToDouble();
                return LineChart(
                  LineChartData(
                    minY: loY,
                    maxY: hiY,
                    titlesData: const FlTitlesData(show: false),
                    gridData: const FlGridData(show: false),
                    borderData: FlBorderData(show: false),
                    lineBarsData: [
                      LineChartBarData(
                        spots: spots,
                        isCurved: true,
                        curveSmoothness: 0.25,
                        barWidth: 3,
                        color: T.primary,
                        dotData: const FlDotData(show: false),
                        belowBarData: BarAreaData(
                          show: true,
                          color: T.primary.withValues(alpha: 0.10),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _DailySummaryCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return NeuCard(
      onTap: () => context.go(Routes.chat),
      color: T.primarySoft,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.psychology_rounded, color: T.primary),
          const SizedBox(width: T.space3),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Ask the assistant',
                  style: T.bodyStrong.copyWith(color: T.primary),
                ),
                const SizedBox(height: 2),
                Text(
                  'Get a plain-language take on today\'s readings.',
                  style: T.caption.copyWith(color: T.primary),
                ),
              ],
            ),
          ),
          const Icon(Icons.arrow_forward_rounded, color: T.primary),
        ],
      ),
    );
  }
}

Stream<_LiveVitals> _liveVitals(WidgetRef ref) {
  final ble = ref.watch(bleServiceProvider);
  return Rx.combineLatest5<
    double?,
    double?,
    double?,
    int,
    ImuFrame?,
    _LiveVitals
  >(
    ble.hr$,
    ble.spo2$,
    ble.temp$,
    ble.activity$,
    ble.imu$,
    (hr, spo2, temp, activity, imu) => _LiveVitals(
      hr: hr,
      spo2: spo2,
      temp: temp,
      activity: activity,
      imu: imu,
      status: ble.status,
    ),
  );
}

class _LiveVitals {
  const _LiveVitals({
    this.hr,
    this.spo2,
    this.temp,
    this.activity = 0,
    this.imu,
    this.status,
  });

  final double? hr;
  final double? spo2;
  final double? temp;
  final int activity;
  final ImuFrame? imu;
  final BleStatus? status;
}
