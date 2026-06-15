import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../app/router.dart';
import '../../core/db/database.dart';
import '../../core/providers.dart';
import '../../core/theme/tokens.dart';
import '../../shared/widgets/widgets.dart';

enum _Range { day, week, month }

class HistoryScreen extends ConsumerStatefulWidget {
  const HistoryScreen({super.key});

  @override
  ConsumerState<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends ConsumerState<HistoryScreen> {
  _Range _range = _Range.day;
  DateTime _anchor = DateTime.now();

  Duration get _windowDuration => switch (_range) {
    _Range.day => const Duration(days: 1),
    _Range.week => const Duration(days: 7),
    _Range.month => const Duration(days: 30),
  };

  String _label() => switch (_range) {
    _Range.day => DateFormat.yMMMMd().format(_anchor),
    _Range.week =>
      'Week of ${DateFormat.yMMMd().format(_anchor.subtract(const Duration(days: 6)))}',
    _Range.month => DateFormat.yMMMM().format(_anchor),
  };

  @override
  Widget build(BuildContext context) {
    final repo = ref.watch(sensorRepoProvider);
    final to = _anchor.millisecondsSinceEpoch;
    final from = _anchor.subtract(_windowDuration).millisecondsSinceEpoch;
    return NeuScaffold(
      title: 'History',
      actions: [
        NeuIconButton(
          icon: Icons.ios_share_rounded,
          tooltip: 'Health report',
          onPressed: () => context.go(Routes.healthReport),
        ),
      ],
      scrollable: true,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          NeuCard(
            child: Row(
              children: [
                NeuIconButton(
                  icon: Icons.chevron_left_rounded,
                  onPressed: () => setState(() {
                    _anchor = _anchor.subtract(_windowDuration);
                  }),
                ),
                Expanded(
                  child: Center(child: Text(_label(), style: T.bodyStrong)),
                ),
                NeuIconButton(
                  icon: Icons.chevron_right_rounded,
                  onPressed: () => setState(() {
                    _anchor = _anchor.add(_windowDuration);
                  }),
                ),
              ],
            ),
          ),
          const SizedBox(height: T.space4),
          Row(
            children: [
              for (final r in _Range.values) ...[
                Expanded(
                  child: NeuChip(
                    label: r.name.toUpperCase(),
                    selected: _range == r,
                    onPressed: () => setState(() => _range = r),
                  ),
                ),
                if (r != _Range.values.last) const SizedBox(width: T.space2),
              ],
            ],
          ),
          const SizedBox(height: T.space5),
          _ChartCard(
            title: 'Heart rate (bpm)',
            color: T.danger,
            future: repo
                .ppgInRange(from, to)
                .then(
                  (samples) =>
                      samples.map((s) => _Pt(s.tsMs, s.hrBpm)).toList(),
                ),
          ),
          const SizedBox(height: T.space4),
          _ChartCard(
            title: 'Skin temperature (°C)',
            color: T.warning,
            future: repo
                .tempInRange(from, to)
                .then(
                  (samples) =>
                      samples.map((s) => _Pt(s.tsMs, s.celsius)).toList(),
                ),
          ),
          const SizedBox(height: T.space5),
          _StatsCard(from: from, to: to),
        ],
      ),
    );
  }
}

class _Pt {
  const _Pt(this.tsMs, this.value);
  final int tsMs;
  final double value;
}

class _ChartCard extends StatelessWidget {
  const _ChartCard({
    required this.title,
    required this.color,
    required this.future,
  });

  final String title;
  final Color color;
  final Future<List<_Pt>> future;

  @override
  Widget build(BuildContext context) {
    return NeuCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(color: color, shape: BoxShape.circle),
              ),
              const SizedBox(width: T.space2),
              Text(title.toUpperCase(), style: T.label),
            ],
          ),
          const SizedBox(height: T.space3),
          SizedBox(
            height: 160,
            child: FutureBuilder<List<_Pt>>(
              future: future,
              builder: (context, snap) {
                if (!snap.hasData) {
                  return Center(
                    child: Text(
                      'Loading…',
                      style: T.caption.copyWith(color: T.inkMuted),
                    ),
                  );
                }
                final pts = snap.data!;
                if (pts.isEmpty) {
                  return Center(
                    child: Text(
                      'No data in this period',
                      style: T.caption.copyWith(color: T.inkMuted),
                    ),
                  );
                }
                final ys = pts.map((p) => p.value).toList()..sort();
                final loY = (ys.first - 4).floorToDouble();
                final hiY = (ys.last + 4).ceilToDouble();
                return LineChart(
                  LineChartData(
                    minY: loY,
                    maxY: hiY,
                    titlesData: FlTitlesData(
                      bottomTitles: const AxisTitles(),
                      topTitles: const AxisTitles(),
                      rightTitles: const AxisTitles(),
                      leftTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          reservedSize: 32,
                          getTitlesWidget: (v, _) =>
                              Text(v.toStringAsFixed(0), style: T.caption),
                          interval: ((hiY - loY) / 4).clamp(1, 999).toDouble(),
                        ),
                      ),
                    ),
                    gridData: FlGridData(
                      show: true,
                      horizontalInterval: ((hiY - loY) / 4)
                          .clamp(1, 999)
                          .toDouble(),
                      getDrawingHorizontalLine: (_) => FlLine(
                        color: T.divider,
                        strokeWidth: 1,
                        dashArray: [4, 6],
                      ),
                      drawVerticalLine: false,
                    ),
                    borderData: FlBorderData(show: false),
                    lineBarsData: [
                      LineChartBarData(
                        spots: [
                          for (var i = 0; i < pts.length; i++)
                            FlSpot(i.toDouble(), pts[i].value),
                        ],
                        isCurved: true,
                        curveSmoothness: 0.18,
                        barWidth: 2.4,
                        color: color,
                        dotData: const FlDotData(show: false),
                        belowBarData: BarAreaData(
                          show: true,
                          color: color.withValues(alpha: 0.08),
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

class _StatsCard extends ConsumerWidget {
  const _StatsCard({required this.from, required this.to});
  final int from;
  final int to;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final repo = ref.watch(sensorRepoProvider);
    return FutureBuilder<List<PpgSample>>(
      future: repo.ppgInRange(from, to),
      builder: (context, snap) {
        if (!snap.hasData) return const SizedBox.shrink();
        final hrs = snap.data!.map((s) => s.hrBpm).toList()..sort();
        if (hrs.isEmpty) {
          return NeuCard(
            child: Center(
              child: Text('No readings in this period', style: T.caption),
            ),
          );
        }
        final mean = hrs.reduce((a, b) => a + b) / hrs.length;
        final p10 = hrs[(hrs.length * 0.1).floor()];
        final p90 = hrs[(hrs.length * 0.9).floor()];
        return NeuCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Heart rate summary'.toUpperCase(), style: T.label),
              const SizedBox(height: T.space3),
              Row(
                children: [
                  _Stat(
                    label: 'Average',
                    value: mean.toStringAsFixed(0),
                    unit: 'bpm',
                  ),
                  _Stat(
                    label: 'Lower range',
                    value: p10.toStringAsFixed(0),
                    unit: 'bpm',
                  ),
                  _Stat(
                    label: 'Upper range',
                    value: p90.toStringAsFixed(0),
                    unit: 'bpm',
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}

class _Stat extends StatelessWidget {
  const _Stat({required this.label, required this.value, required this.unit});
  final String label;
  final String value;
  final String unit;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: T.caption.copyWith(color: T.inkMuted)),
          const SizedBox(height: 2),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(value, style: T.metricSmall),
              const SizedBox(width: 4),
              Text(unit, style: T.caption.copyWith(color: T.inkMuted)),
            ],
          ),
        ],
      ),
    );
  }
}
