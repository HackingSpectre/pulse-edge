import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../app/router.dart';
import '../../core/alerts/alert_severity.dart';
import '../../core/db/database.dart';
import '../../core/providers.dart';
import '../../core/theme/tokens.dart';
import '../../shared/widgets/widgets.dart';

class AlertDetailScreen extends ConsumerStatefulWidget {
  const AlertDetailScreen({super.key, required this.id});
  final String id;

  @override
  ConsumerState<AlertDetailScreen> createState() => _AlertDetailScreenState();
}

class _AlertDetailScreenState extends ConsumerState<AlertDetailScreen> {
  String? _llmExplanation;
  bool _loadingLlm = false;

  Future<void> _askLlm(AnomalyRow row) async {
    setState(() => _loadingLlm = true);
    final llm = ref.read(llmServiceProvider);
    final txt = await llm.explainAnomaly(
      type: AlertType.fromId(row.type).label,
      metricsJson: row.metricsJson,
    );
    if (!mounted) return;
    setState(() {
      _llmExplanation = txt;
      _loadingLlm = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final repo = ref.watch(anomalyRepoProvider);
    return NeuScaffold(
      title: 'Alert',
      showBack: true,
      scrollable: true,
      onBack: () => context.go(Routes.alerts),
      body: FutureBuilder<AnomalyRow?>(
        future: repo.byId(widget.id),
        builder: (context, snap) {
          if (snap.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          final row = snap.data;
          if (row == null) {
            return NeuEmptyState(
              icon: Icons.error_outline_rounded,
              title: 'Not found',
              message: 'This alert was deleted or doesn\'t exist anymore.',
              actionLabel: 'Back to alerts',
              onAction: () => context.go(Routes.alerts),
            );
          }
          final sev = AlertSeverity.fromCode(row.severity);
          final type = AlertType.fromId(row.type);
          final ts = DateTime.fromMillisecondsSinceEpoch(row.tsMs);
          final metrics = (jsonDecode(row.metricsJson) as Map)
              .cast<String, Object?>();
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              NeuCard(
                color: sev.color.withValues(alpha: 0.06),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        NeuSeverityBadge(
                          label: sev.label.toUpperCase(),
                          color: sev.color,
                        ),
                        const SizedBox(width: T.space2),
                        Text(
                          DateFormat.yMMMd().add_jm().format(ts),
                          style: T.caption,
                        ),
                      ],
                    ),
                    const SizedBox(height: T.space3),
                    Text(type.label, style: T.h2),
                    const SizedBox(height: T.space2),
                    Text(row.explanation ?? '', style: T.body),
                  ],
                ),
              ),
              const SizedBox(height: T.space4),
              NeuCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Readings at the time'.toUpperCase(), style: T.label),
                    const SizedBox(height: T.space3),
                    for (final entry in metrics.entries)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: Row(
                          children: [
                            Text(_metricLabel(entry.key), style: T.caption),
                            const Spacer(),
                            Text(
                              entry.value == null
                                  ? '-'
                                  : entry.value.toString(),
                              style: T.body.copyWith(
                                fontFamily: T.fontMono,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: T.space4),
              if (row.guidance != null)
                NeuCard(
                  color: T.primarySoft,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(Icons.tips_and_updates_rounded, color: T.primary),
                      const SizedBox(width: T.space3),
                      Expanded(
                        child: Text(
                          row.guidance!,
                          style: T.body.copyWith(color: T.primary),
                        ),
                      ),
                    ],
                  ),
                ),
              const SizedBox(height: T.space4),
              NeuCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.psychology_rounded, color: T.info),
                        const SizedBox(width: T.space2),
                        Text(
                          'Assistant explanation'.toUpperCase(),
                          style: T.label,
                        ),
                      ],
                    ),
                    const SizedBox(height: T.space3),
                    if (_llmExplanation != null)
                      Text(_llmExplanation!, style: T.body)
                    else
                      NeuButton(
                        label: _loadingLlm
                            ? 'Generating…'
                            : 'Ask the assistant',
                        loading: _loadingLlm,
                        icon: Icons.auto_awesome_rounded,
                        onPressed: () => _askLlm(row),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: T.space5),
              Row(
                children: [
                  Expanded(
                    child: NeuButton(
                      label: 'Mark as not an issue',
                      icon: Icons.thumb_up_off_alt_rounded,
                      variant: NeuButtonVariant.subtle,
                      onPressed: row.markedNotAnomalous
                          ? null
                          : () async {
                              await repo.dismiss(
                                row.id,
                                markNotAnomalous: true,
                              );
                              if (!context.mounted) return;
                              context.go(Routes.alerts);
                            },
                    ),
                  ),
                  const SizedBox(width: T.space3),
                  Expanded(
                    child: NeuButton(
                      label: 'Dismiss',
                      icon: Icons.check_rounded,
                      variant: NeuButtonVariant.filled,
                      onPressed: row.dismissedAtMs != null
                          ? null
                          : () async {
                              await repo.dismiss(row.id);
                              if (!context.mounted) return;
                              context.go(Routes.alerts);
                            },
                    ),
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );
  }

  String _metricLabel(String key) {
    return switch (key) {
      'hrMean' => 'Heart rate average',
      'hrMin' => 'Heart rate low',
      'hrMax' => 'Heart rate high',
      'hrStd' => 'Heart rate change',
      'rmssd' => 'Heart rhythm variation',
      'spo2' || 'spo2Mean' => 'Blood oxygen',
      'tempMean' => 'Skin temperature',
      'activity' => 'Activity',
      'accelMean' => 'Movement',
      'accelStd' => 'Movement change',
      'modelP' || 'anomalyP' => 'Pattern score',
      _ => key,
    };
  }
}
