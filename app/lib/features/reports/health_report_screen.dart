import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';

import '../../core/export/health_report_service.dart';
import '../../core/providers.dart';
import '../../core/theme/tokens.dart';
import '../../shared/widgets/widgets.dart';

enum _ReportRange {
  day('24H', Duration(days: 1)),
  week('7D', Duration(days: 7)),
  month('30D', Duration(days: 30));

  const _ReportRange(this.label, this.duration);
  final String label;
  final Duration duration;
}

class HealthReportScreen extends ConsumerStatefulWidget {
  const HealthReportScreen({super.key});

  @override
  ConsumerState<HealthReportScreen> createState() => _HealthReportScreenState();
}

class _HealthReportScreenState extends ConsumerState<HealthReportScreen> {
  _ReportRange _range = _ReportRange.week;
  bool _saving = false;
  bool _sharing = false;

  DateTime get _to => DateTime.now();
  DateTime get _from => _to.subtract(_range.duration);

  @override
  Widget build(BuildContext context) {
    final period = _periodLabel(_from, _to);
    return NeuScaffold(
      title: 'Health report',
      scrollable: true,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          NeuCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.ios_share_rounded, color: T.primary),
                    const SizedBox(width: T.space3),
                    Expanded(
                      child: Text(
                        'Share with your doctor'.toUpperCase(),
                        style: T.label,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: T.space3),
                Text(
                  'Creates a clear summary from your saved readings, trends, '
                  'and alerts.',
                  style: T.body.copyWith(color: T.inkSoft),
                ),
                const SizedBox(height: T.space4),
                Text(period, style: T.bodyStrong),
              ],
            ),
          ),
          const SizedBox(height: T.space5),
          Row(
            children: [
              for (final r in _ReportRange.values) ...[
                Expanded(
                  child: NeuChip(
                    label: r.label,
                    selected: _range == r,
                    onPressed: () => setState(() => _range = r),
                  ),
                ),
                if (r != _ReportRange.values.last)
                  const SizedBox(width: T.space2),
              ],
            ],
          ),
          const SizedBox(height: T.space5),
          NeuListGroup(
            children: const [
              NeuListTile(
                icon: Icons.favorite_rounded,
                title: 'Vitals summary',
                subtitle:
                    'Heart rate, blood oxygen, temperature, and movement.',
              ),
              NeuListTile(
                icon: Icons.notifications_active_rounded,
                title: 'Alert history',
                subtitle: 'Important readings and when alerts happened.',
              ),
              NeuListTile(
                icon: Icons.description_rounded,
                title: 'Summary files',
                subtitle: 'Readable summary plus a detailed readings file.',
              ),
            ],
          ),
          const SizedBox(height: T.space5),
          NeuButton(
            label: 'Share to doctor',
            icon: Icons.mail_outline_rounded,
            variant: NeuButtonVariant.filled,
            expanded: true,
            loading: _sharing,
            onPressed: _saving || _sharing ? null : _shareReport,
          ),
          const SizedBox(height: T.space3),
          NeuButton(
            label: 'Save report',
            icon: Icons.download_rounded,
            expanded: true,
            loading: _saving,
            onPressed: _saving || _sharing ? null : _saveReport,
          ),
          const SizedBox(height: T.space4),
          Text(
            'The summary is not a diagnosis. It is a structured handoff for your doctor.',
            textAlign: TextAlign.center,
            style: T.caption.copyWith(color: T.inkMuted),
          ),
        ],
      ),
    );
  }

  Future<void> _shareReport() async {
    setState(() => _sharing = true);
    try {
      final bundle = await _createReport();
      if (!mounted) return;
      if (!bundle.hasData) {
        _showMessage('No stored health data found for this period yet.');
        return;
      }
      final box = context.findRenderObject() as RenderBox?;
      await SharePlus.instance.share(
        ShareParams(
          title: 'Pulse Edge health summary',
          subject: bundle.subject,
          text: bundle.shareText,
          files: [for (final file in bundle.files) XFile(file.path)],
          sharePositionOrigin: box == null
              ? null
              : box.localToGlobal(Offset.zero) & box.size,
        ),
      );
    } catch (e) {
      if (mounted) _showMessage('Could not share report: $e');
    } finally {
      if (mounted) setState(() => _sharing = false);
    }
  }

  Future<void> _saveReport() async {
    setState(() => _saving = true);
    try {
      final bundle = await _createReport();
      if (!mounted) return;
      if (!bundle.hasData) {
        _showMessage('No stored health data found for this period yet.');
        return;
      }
      _showMessage('Saved: ${bundle.summaryFile.parent.path}');
    } catch (e) {
      if (mounted) _showMessage('Could not save report: $e');
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<HealthReportBundle> _createReport() {
    return ref
        .read(healthReportServiceProvider)
        .createReport(from: _from, to: _to);
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  String _periodLabel(DateTime from, DateTime to) {
    final fmt = DateFormat.yMMMd().add_jm();
    return '${fmt.format(from)} - ${fmt.format(to)}';
  }
}
