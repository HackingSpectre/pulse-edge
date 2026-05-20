import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/theme/tokens.dart';
import 'neu_surface.dart';

/// On-screen number keypad used by the PIN auth screens. Renders a 3×4 grid
/// of large neumorphic key surfaces.
class NeuPinKeypad extends StatelessWidget {
  const NeuPinKeypad({
    super.key,
    required this.onDigit,
    required this.onBackspace,
    this.onBiometric,
    this.spacing = T.space4,
  });

  final ValueChanged<int> onDigit;
  final VoidCallback onBackspace;
  final VoidCallback? onBiometric;
  final double spacing;

  @override
  Widget build(BuildContext context) {
    final rows = <List<_KeyDef>>[
      [_digit(1), _digit(2), _digit(3)],
      [_digit(4), _digit(5), _digit(6)],
      [_digit(7), _digit(8), _digit(9)],
      [
        onBiometric != null
            ? _icon(Icons.fingerprint_rounded, onBiometric!, label: 'Biometric')
            : _empty(),
        _digit(0),
        _icon(Icons.backspace_rounded, onBackspace, label: 'Backspace'),
      ],
    ];
    return LayoutBuilder(
      builder: (context, constraints) {
        // Cap key size so the keypad doesn't dominate small phones.
        final maxKey = (constraints.maxWidth - spacing * 2) / 3;
        final keySize = maxKey.clamp(64.0, 88.0);
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (final row in rows) ...[
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  for (final k in row) ...[
                    SizedBox(
                      width: keySize,
                      height: keySize,
                      child: k.empty
                          ? const SizedBox.shrink()
                          : _Key(def: k),
                    ),
                    if (k != row.last) SizedBox(width: spacing),
                  ],
                ],
              ),
              if (row != rows.last) SizedBox(height: spacing),
            ],
          ],
        );
      },
    );
  }

  _KeyDef _digit(int n) =>
      _KeyDef(label: '$n', onTap: () => onDigit(n));
  _KeyDef _icon(IconData icon, VoidCallback onTap, {required String label}) =>
      _KeyDef(icon: icon, onTap: onTap, semantic: label);
  _KeyDef _empty() => const _KeyDef(empty: true);
}

class _KeyDef {
  const _KeyDef({this.label, this.icon, this.onTap, this.semantic, this.empty = false});
  final String? label;
  final IconData? icon;
  final VoidCallback? onTap;
  final String? semantic;
  final bool empty;
}

class _Key extends StatefulWidget {
  const _Key({required this.def});
  final _KeyDef def;

  @override
  State<_Key> createState() => _KeyState();
}

class _KeyState extends State<_Key> with SingleTickerProviderStateMixin {
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

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: widget.def.semantic ?? widget.def.label,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTapDown: (_) {
          _c.forward();
          HapticFeedback.selectionClick();
        },
        onTapUp: (_) {
          _c.reverse();
          widget.def.onTap?.call();
        },
        onTapCancel: () => _c.reverse(),
        child: AnimatedBuilder(
          animation: _c,
          builder: (context, _) {
            final pressed = _c.value > 0.5;
            return NeuSurface(
              depth: pressed ? NeuDepth.sunken : NeuDepth.raised,
              size: NeuSize.md,
              borderRadius: T.brXl,
              alignment: Alignment.center,
              child: widget.def.icon != null
                  ? Icon(widget.def.icon, size: T.iconLg, color: T.inkSoft)
                  : Text(
                      widget.def.label!,
                      style: T.h1.copyWith(
                        fontWeight: FontWeight.w400,
                        fontSize: 28,
                      ),
                    ),
            );
          },
        ),
      ),
    );
  }
}

/// Visual indicator of how many PIN digits have been entered.
class NeuPinDots extends StatelessWidget {
  const NeuPinDots({
    super.key,
    required this.length,
    required this.entered,
    this.shake = false,
  });

  final int length;
  final int entered;
  final bool shake;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: shake ? 1 : 0),
      duration: const Duration(milliseconds: 380),
      builder: (context, t, child) {
        // Damped sine wave for shake.
        final dx = shake ? (16.0 * (1 - t) * (t * 24).remainder(2.0) - 8.0) : 0.0;
        return Transform.translate(
          offset: Offset(dx, 0),
          child: child,
        );
      },
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(length, (i) {
          final filled = i < entered;
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: T.space2),
            child: AnimatedContainer(
              duration: T.motionFast,
              width: filled ? 14 : 10,
              height: filled ? 14 : 10,
              decoration: BoxDecoration(
                color: filled ? T.primary : T.surfaceSunken,
                shape: BoxShape.circle,
                boxShadow: filled
                    ? [BoxShadow(color: T.primary.withValues(alpha: 0.40), blurRadius: 8)]
                    : null,
              ),
            ),
          );
        }),
      ),
    );
  }
}
