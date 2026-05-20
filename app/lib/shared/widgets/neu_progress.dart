import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../core/theme/tokens.dart';

/// Linear progress indicator drawn into a sunken track. Used for
/// onboarding step progress and the LLM model download.
class NeuLinearProgress extends StatelessWidget {
  const NeuLinearProgress({
    super.key,
    required this.value,
    this.color,
    this.height = 10,
  });

  final double value;
  final Color? color;
  final double height;

  @override
  Widget build(BuildContext context) {
    final v = value.clamp(0.0, 1.0);
    return Container(
      height: height,
      decoration: BoxDecoration(
        color: T.surfaceSunken,
        borderRadius: BorderRadius.circular(height / 2),
        boxShadow: [
          BoxShadow(
            color: T.shadowDark.withValues(alpha: 0.25),
            offset: const Offset(2, 2),
            blurRadius: 4,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(height / 2),
        child: Align(
          alignment: Alignment.centerLeft,
          child: AnimatedFractionallySizedBox(
            duration: T.motionBase,
            curve: T.emphasized,
            heightFactor: 1,
            widthFactor: v,
            child: Container(
              decoration: BoxDecoration(
                color: color ?? T.primary,
                borderRadius: BorderRadius.circular(height / 2),
                boxShadow: [
                  BoxShadow(
                    color: (color ?? T.primary).withValues(alpha: 0.40),
                    offset: const Offset(0, 2),
                    blurRadius: 6,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// The hero metric ring on the dashboard (HR, etc.). Sunken track with a
/// glowing primary stroke, big numeric label centered.
class NeuMetricRing extends StatelessWidget {
  const NeuMetricRing({
    super.key,
    required this.value,
    required this.label,
    required this.unit,
    this.fill = 0.6,
    this.color,
    this.size = 220,
    this.subtitle,
  });

  final String value;
  final String label;
  final String unit;

  /// 0..1 — how full the ring is.
  final double fill;
  final Color? color;
  final double size;
  final Widget? subtitle;

  @override
  Widget build(BuildContext context) {
    final accent = color ?? T.primary;
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: T.surface,
              boxShadow: T.raisedLg(),
            ),
          ),
          // Sunken track + animated arc.
          Padding(
            padding: const EdgeInsets.all(14),
            child: TweenAnimationBuilder<double>(
              duration: T.motionSlow,
              curve: T.emphasized,
              tween: Tween(begin: 0, end: fill.clamp(0.0, 1.0)),
              builder: (context, v, _) => CustomPaint(
                painter: _RingPainter(value: v, color: accent),
              ),
            ),
          ),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(label.toUpperCase(), style: T.label),
              const SizedBox(height: T.space2),
              Text(value, style: T.metricHero),
              const SizedBox(height: T.space1),
              Text(unit.toUpperCase(),
                  style: T.label.copyWith(color: T.inkMuted)),
              if (subtitle != null) ...[
                const SizedBox(height: T.space3),
                subtitle!,
              ],
            ],
          ),
        ],
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  _RingPainter({required this.value, required this.color});

  final double value;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final center = rect.center;
    final radius = (math.min(size.width, size.height) / 2) - 8;

    // Sunken track.
    final track = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 14
      ..color = T.surfaceSunken;
    canvas.drawCircle(center, radius, track);

    final inner = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 14
      ..color = T.shadowLight.withValues(alpha: 0.7);
    canvas.drawCircle(center.translate(-1, -1), radius, inner);

    // Glow under arc.
    final glow = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 18
      ..strokeCap = StrokeCap.round
      ..color = color.withValues(alpha: 0.20)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2,
      2 * math.pi * value,
      false,
      glow,
    );

    // Arc.
    final arc = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 12
      ..strokeCap = StrokeCap.round
      ..color = color;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2,
      2 * math.pi * value,
      false,
      arc,
    );
  }

  @override
  bool shouldRepaint(covariant _RingPainter old) =>
      old.value != value || old.color != color;
}
