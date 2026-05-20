import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import '../../core/theme/tokens.dart';

/// The visual depth mode of a [NeuSurface].
enum NeuDepth {
  /// Extruded outward — the default for cards, buttons at rest.
  raised,

  /// No shadows — flat plate. Used for backgrounds inside already-raised cards.
  flat,

  /// Pressed inward — used for active toggles, focused inputs, and the
  /// "depressed" state of [NeuButton] when held.
  sunken,
}

enum NeuSize { sm, md, lg }

/// Foundational building block for every neumorphic surface in the app.
///
/// Renders a same-hue-as-background container with two opposing shadows
/// (soft highlight from the top-left, soft drop from the bottom-right) for
/// a tactile extruded/embedded look. When [depth] is [NeuDepth.sunken],
/// inset shadows are drawn instead via a [CustomPainter] (Flutter's
/// `BoxShadow` is outer-only).
///
/// Anti-pattern (do NOT do): drawing a hard border, gradient fill, or any
/// color other than the surface tones — neumorphism's whole point is that
/// shadow shape carries hierarchy, not color contrast.
class NeuSurface extends StatelessWidget {
  const NeuSurface({
    super.key,
    this.depth = NeuDepth.raised,
    this.size = NeuSize.md,
    this.borderRadius = T.brMd,
    this.padding,
    this.color,
    this.width,
    this.height,
    this.alignment,
    this.clipBehavior = Clip.none,
    this.child,
  });

  final NeuDepth depth;
  final NeuSize size;
  final BorderRadius borderRadius;
  final EdgeInsetsGeometry? padding;
  final Color? color;
  final double? width;
  final double? height;
  final AlignmentGeometry? alignment;
  final Clip clipBehavior;
  final Widget? child;

  List<BoxShadow> _shadows() {
    switch (size) {
      case NeuSize.sm:
        return T.raisedSm();
      case NeuSize.md:
        return T.raisedMd();
      case NeuSize.lg:
        return T.raisedLg();
    }
  }

  double _insetBlur() {
    switch (size) {
      case NeuSize.sm:
        return T.blurSm;
      case NeuSize.md:
        return T.blurMd;
      case NeuSize.lg:
        return T.blurLg;
    }
  }

  Offset _insetOffset() {
    switch (size) {
      case NeuSize.sm:
        return T.offsetSm;
      case NeuSize.md:
        return T.offsetMd;
      case NeuSize.lg:
        return T.offsetLg;
    }
  }

  @override
  Widget build(BuildContext context) {
    final fill = color ?? T.surface;

    Widget content = child ?? const SizedBox.shrink();
    if (padding != null) content = Padding(padding: padding!, child: content);
    if (alignment != null) content = Align(alignment: alignment!, child: content);

    if (clipBehavior != Clip.none) {
      content = ClipRRect(
        borderRadius: borderRadius,
        clipBehavior: clipBehavior,
        child: content,
      );
    }

    if (depth == NeuDepth.sunken) {
      return SizedBox(
        width: width,
        height: height,
        child: CustomPaint(
          painter: _InsetShadowPainter(
            color: fill,
            borderRadius: borderRadius,
            blur: _insetBlur(),
            offset: _insetOffset(),
          ),
          child: ClipRRect(
            borderRadius: borderRadius,
            child: content,
          ),
        ),
      );
    }

    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: fill,
        borderRadius: borderRadius,
        boxShadow: depth == NeuDepth.raised ? _shadows() : null,
      ),
      child: content,
    );
  }
}

/// CustomPainter that fakes an inset (inner) shadow inside a rounded rect.
///
/// Strategy: fill with the surface color, then over the top draw two
/// large blurred-edge rects clipped to the inverse of the inner area —
/// one bright (top-left), one dark (bottom-right). The result reads as
/// if the surface has been pressed into the canvas.
class _InsetShadowPainter extends CustomPainter {
  _InsetShadowPainter({
    required this.color,
    required this.borderRadius,
    required this.blur,
    required this.offset,
  });

  final Color color;
  final BorderRadius borderRadius;
  final double blur;
  final Offset offset;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final rrect = borderRadius.toRRect(rect);

    // Base fill — same hue as surrounding canvas.
    canvas.drawRRect(rrect, Paint()..color = color);

    canvas.save();
    canvas.clipRRect(rrect);

    // Dark inner shadow from top-left.
    _drawInnerShadow(
      canvas,
      rect,
      rrect,
      shadowColor: T.shadowDark.withValues(alpha: 0.55),
      shadowOffset: offset,
      blur: blur,
    );

    // Light inner shadow from bottom-right (highlight peeks through).
    _drawInnerShadow(
      canvas,
      rect,
      rrect,
      shadowColor: T.shadowLight.withValues(alpha: 1.0),
      shadowOffset: -offset,
      blur: blur,
    );

    canvas.restore();
  }

  void _drawInnerShadow(
    Canvas canvas,
    Rect rect,
    RRect rrect, {
    required Color shadowColor,
    required Offset shadowOffset,
    required double blur,
  }) {
    final paint = Paint()
      ..color = shadowColor
      ..maskFilter = MaskFilter.blur(BlurStyle.normal, blur);
    final outerPath = Path()..addRect(rect.inflate(blur * 4));
    final innerPath = Path()..addRRect(rrect.shift(shadowOffset));
    final shadowPath = Path.combine(PathOperation.difference, outerPath, innerPath);
    canvas.drawPath(shadowPath, paint);
  }

  @override
  bool shouldRepaint(covariant _InsetShadowPainter old) {
    return old.color != color ||
        old.borderRadius != borderRadius ||
        old.blur != blur ||
        old.offset != offset;
  }
}

/// Helper that wraps a [NeuSurface] around any child with sensible defaults
/// for use as a content card.
class NeuCard extends StatelessWidget {
  const NeuCard({
    super.key,
    this.padding = const EdgeInsets.all(T.space5),
    this.borderRadius = T.brLg,
    this.depth = NeuDepth.raised,
    this.size = NeuSize.md,
    this.color,
    this.onTap,
    required this.child,
  });

  final EdgeInsetsGeometry padding;
  final BorderRadius borderRadius;
  final NeuDepth depth;
  final NeuSize size;
  final Color? color;
  final VoidCallback? onTap;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final surface = NeuSurface(
      depth: depth,
      size: size,
      borderRadius: borderRadius,
      padding: padding,
      color: color,
      child: child,
    );
    final tap = onTap;
    if (tap == null) return surface;
    return _PressShrink(
      onTap: tap,
      borderRadius: borderRadius,
      child: surface,
    );
  }
}

/// Tiny press-feedback wrapper used by tappable cards. Shrinks 2% on press.
/// The matching [NeuButton] uses a depth-flip animation instead.
class _PressShrink extends StatefulWidget {
  const _PressShrink({
    required this.onTap,
    required this.child,
    required this.borderRadius,
  });

  final VoidCallback onTap;
  final Widget child;
  final BorderRadius borderRadius;

  @override
  State<_PressShrink> createState() => _PressShrinkState();
}

class _PressShrinkState extends State<_PressShrink> with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: T.motionFast,
    reverseDuration: const Duration(milliseconds: 180),
    lowerBound: 0,
    upperBound: 1,
  );

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  void _down() => _c.forward();
  void _up() => _c.reverse();

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTapDown: (_) => _down(),
      onTapUp: (_) {
        _up();
        widget.onTap();
      },
      onTapCancel: _up,
      child: AnimatedBuilder(
        animation: _c,
        builder: (context, child) {
          final s = ui.lerpDouble(1.0, 0.97, _c.value)!;
          return Transform.scale(scale: s, child: child);
        },
        child: widget.child,
      ),
    );
  }
}
