import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../core/alerts/alert_severity.dart';
import '../../core/db/database.dart';
import '../../core/providers.dart';
import '../../core/theme/tokens.dart';
import '../../shared/widgets/widgets.dart';

class AlertsScreen extends ConsumerWidget {
  const AlertsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final repo = ref.watch(anomalyRepoProvider);
    return NeuScaffold(
      title: 'Alerts',
      scrollable: false,
      padding: EdgeInsets.zero,
      body: StreamBuilder<List<AnomalyRow>>(
        stream: repo.watchAll(),
        builder: (context, snap) {
          final rows = snap.data ?? const <AnomalyRow>[];
          if (rows.isEmpty) {
            return NeuEmptyState(
              icon: Icons.shield_rounded,
              title: 'All quiet',
              message:
                  'When something looks unusual, it shows up here. The first '
                  'week of data feeds the personalized baseline before the '
                  'pattern detector kicks in.',
              tone: T.success,
            );
          }
          // Group by day.
          final groups = <String, List<AnomalyRow>>{};
          for (final r in rows) {
            final day = DateFormat.yMMMd().format(
              DateTime.fromMillisecondsSinceEpoch(r.tsMs),
            );
            groups.putIfAbsent(day, () => []).add(r);
          }
          return ListView(
            padding: const EdgeInsets.fromLTRB(
              T.pagePadding,
              T.space2,
              T.pagePadding,
              T.space7,
            ),
            children: [
              for (final entry in groups.entries) ...[
                Padding(
                  padding: const EdgeInsets.only(
                    top: T.space5,
                    bottom: T.space2,
                  ),
                  child: Text(entry.key.toUpperCase(), style: T.label),
                ),
                for (final r in entry.value) ...[
                  _AlertRow(row: r),
                  const SizedBox(height: T.space3),
                ],
              ],
            ],
          );
        },
      ),
    );
  }
}

class _AlertRow extends StatelessWidget {
  const _AlertRow({required this.row});
  final AnomalyRow row;

  @override
  Widget build(BuildContext context) {
    final sev = AlertSeverity.fromCode(row.severity);
    final type = AlertType.fromId(row.type);
    final time = DateFormat.Hm().format(
      DateTime.fromMillisecondsSinceEpoch(row.tsMs),
    );
    return NeuCard(
      onTap: () => context.go('/alerts/${row.id}'),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: sev.color.withValues(alpha: 0.14),
              borderRadius: T.brSm,
            ),
            alignment: Alignment.center,
            child: Icon(_iconFor(type), size: T.iconMd, color: sev.color),
          ),
          const SizedBox(width: T.space4),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(child: Text(type.label, style: T.bodyStrong)),
                    NeuSeverityBadge(
                      label: sev.label.toUpperCase(),
                      color: sev.color,
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  row.explanation ?? '',
                  style: T.caption,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(time, style: T.caption.copyWith(color: T.inkMuted)),
              ],
            ),
          ),
          if (row.dismissedAtMs == null)
            Container(
              margin: const EdgeInsets.only(left: T.space2),
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: T.primary,
                shape: BoxShape.circle,
              ),
            ),
        ],
      ),
    );
  }

  IconData _iconFor(AlertType t) => switch (t) {
    AlertType.tachycardia => Icons.favorite_rounded,
    AlertType.bradycardia => Icons.heart_broken_rounded,
    AlertType.hypoxia => Icons.air_rounded,
    AlertType.hyperthermia => Icons.local_fire_department_rounded,
    AlertType.hypothermia => Icons.ac_unit_rounded,
    AlertType.fall => Icons.warning_rounded,
    AlertType.modelAnomaly => Icons.insights_rounded,
  };
}
