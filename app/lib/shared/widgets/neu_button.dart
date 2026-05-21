import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/theme/tokens.dart';
import 'neu_surface.dart';

enum NeuButtonVariant {
  /// Default: surface-toned, primary text. The default action.
  primary,

  /// Filled with primary teal, white text. The hero call-to-action.
  filled,

  /// Subtle: same surface but smaller shadow + muted text. For tertiary.
  subtle,

  /// Danger: red text on surface. For destructive actions.
  danger,
}

/// The default app button. Visually flips from raised → sunken on press
/// (the core neumorphic interaction), with haptic feedback for confirmation.
///
/// Always has a minimum 48dp tap target per WCAG 2.2 AA.
class NeuButton extends StatefulWidget {
  const NeuButton({
    super.key,
    required this.label,
    this.icon,
    this.onPressed,
    this.variant = NeuButtonVariant.primary,
    this.expanded = false,
    this.loading = false,
    this.size = NeuSize.md,
  });

  final String label;
  final IconData? icon;
  final VoidCallback? onPressed;
  final NeuButtonVariant variant;
  final bool expanded;
  final bool loading;
  final NeuSize size;

  bool get _enabled => onPressed != null && !loading;

  @override
  State<NeuButton> createState() => _NeuButtonState();
}

class _NeuButtonState extends State<NeuButton> with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: T.motionFast,
    reverseDuration: const Duration(milliseconds: 180),
  );

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  Color _textColor() {
    if (!widget._enabled) return T.inkDisabled;
    switch (widget.variant) {
      case NeuButtonVariant.primary:
        return T.primary;
      case NeuButtonVariant.filled:
        return T.inkInverse;
      case NeuButtonVariant.subtle:
        return T.inkSoft;
      case NeuButtonVariant.danger:
        return T.danger;
    }
  }

  Color? _fill() {
    if (widget.variant == NeuButtonVariant.filled) {
      return widget._enabled ? T.primary : T.surfaceSunken;
    }
    return null;
  }

  EdgeInsets _padding() {
    switch (widget.size) {
      case NeuSize.sm:
        return const EdgeInsets.symmetric(horizontal: T.space4, vertical: T.space3);
      case NeuSize.md:
        return const EdgeInsets.symmetric(horizontal: T.space6, vertical: T.space4);
      case NeuSize.lg:
        return const EdgeInsets.symmetric(horizontal: T.space7, vertical: T.space5);
    }
  }

  double _height() {
    switch (widget.size) {
      case NeuSize.sm:
        return T.minTap;
      case NeuSize.md:
        return 56;
      case NeuSize.lg:
        return 64;
    }
  }

  TextStyle _textStyle() {
    final base = switch (widget.size) {
      NeuSize.sm => T.bodyStrong,
      NeuSize.md => T.h3,
      NeuSize.lg => T.h2,
    };
    return base.copyWith(color: _textColor(), letterSpacing: 0.2);
  }

  void _down() {
    if (!widget._enabled) return;
    _c.forward();
    HapticFeedback.selectionClick();
  }

  void _up() {
    _c.reverse();
  }

  @override
  Widget build(BuildContext context) {
    final inner = AnimatedBuilder(
      animation: _c,
      builder: (context, _) {
        final pressed = _c.value > 0.5;
        final depth = !widget._enabled
            ? NeuDepth.flat
            : pressed
                ? NeuDepth.sunken
                : NeuDepth.raised;
        return NeuSurface(
          depth: depth,
          size: widget.size,
          borderRadius: T.brLg,
          color: _fill(),
          height: _height(),
          padding: _padding(),
          alignment: Alignment.center,
          child: _content(),
        );
      },
    );

    return Semantics(
      button: true,
      enabled: widget._enabled,
      label: widget.label,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTapDown: (_) => _down(),
        onTap: () {
          _up();
          widget.onPressed?.call();
        },
        onTapCancel: _up,
        child: SizedBox(
          width: widget.expanded ? double.infinity : null,
          child: inner,
        ),
      ),
    );
  }

  Widget _content() {
    if (widget.loading) {
      return SizedBox(
        height: 18,
        width: 18,
        child: CircularProgressIndicator(
          strokeWidth: 2.4,
          valueColor: AlwaysStoppedAnimation(_textColor()),
        ),
      );
    }
    final textChild = Text(
      widget.label,
      style: _textStyle(),
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
    );
    if (widget.icon == null) return textChild;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(widget.icon, size: T.iconSm, color: _textColor()),
        const SizedBox(width: T.space3),
        Flexible(child: textChild),
      ],
    );
  }
}

/// Compact icon-only button. Same press semantics as [NeuButton].
class NeuIconButton extends StatefulWidget {
  const NeuIconButton({
    super.key,
    required this.icon,
    this.onPressed,
    this.size = T.minTap,
    this.iconSize = T.iconMd,
    this.color,
    this.tooltip,
  });

  final IconData icon;
  final VoidCallback? onPressed;
  final double size;
  final double iconSize;
  final Color? color;
  final String? tooltip;

  @override
  State<NeuIconButton> createState() => _NeuIconButtonState();
}

class _NeuIconButtonState extends State<NeuIconButton> with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: T.motionFast,
    reverseDuration: const Duration(milliseconds: 180),
  );

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  void _down() {
    if (widget.onPressed == null) return;
    _c.forward();
    HapticFeedback.selectionClick();
  }

  void _up() => _c.reverse();

  @override
  Widget build(BuildContext context) {
    final btn = AnimatedBuilder(
      animation: _c,
      builder: (context, _) {
        final pressed = _c.value > 0.5;
        return NeuSurface(
          depth: widget.onPressed == null
              ? NeuDepth.flat
              : pressed
                  ? NeuDepth.sunken
                  : NeuDepth.raised,
          size: NeuSize.sm,
          borderRadius: BorderRadius.circular(widget.size / 2),
          width: widget.size,
          height: widget.size,
          alignment: Alignment.center,
          child: Icon(
            widget.icon,
            size: widget.iconSize,
            color: widget.color ??
                (widget.onPressed == null ? T.inkDisabled : T.ink),
          ),
        );
      },
    );

    final wrapped = GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTapDown: (_) => _down(),
      onTapUp: (_) {
        _up();
        widget.onPressed?.call();
      },
      onTapCancel: _up,
      child: btn,
    );

    return Semantics(
      button: true,
      enabled: widget.onPressed != null,
      label: widget.tooltip ?? '',
      child: widget.tooltip == null
          ? wrapped
          : Tooltip(message: widget.tooltip!, child: wrapped),
    );
  }
}
