import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/theme/tokens.dart';
import 'neu_surface.dart';

/// Neumorphic toggle switch. Track is sunken; thumb is raised. Animates
/// the thumb across when toggled. Always 48dp tall hit area.
class NeuSwitch extends StatelessWidget {
  const NeuSwitch({super.key, required this.value, required this.onChanged});

  final bool value;
  final ValueChanged<bool>? onChanged;

  static const double _w = 56;
  static const double _h = 32;
  static const double _thumb = 26;

  @override
  Widget build(BuildContext context) {
    final disabled = onChanged == null;
    return Semantics(
      toggled: value,
      enabled: !disabled,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: disabled
            ? null
            : () {
                HapticFeedback.selectionClick();
                onChanged!(!value);
              },
        child: SizedBox(
          height: T.minTap,
          width: _w,
          child: Center(
            child: SizedBox(
              width: _w,
              height: _h,
              child: NeuSurface(
                depth: NeuDepth.sunken,
                size: NeuSize.sm,
                borderRadius: BorderRadius.circular(_h / 2),
                color: value && !disabled
                    ? T.primary.withValues(alpha: 0.15)
                    : T.surface,
                child: Stack(
                  children: [
                    AnimatedAlign(
                      duration: T.motionBase,
                      curve: T.emphasized,
                      alignment: value
                          ? Alignment.centerRight
                          : Alignment.centerLeft,
                      child: Padding(
                        padding: const EdgeInsets.all(3),
                        child: Container(
                          width: _thumb,
                          height: _thumb,
                          decoration: BoxDecoration(
                            color: value && !disabled
                                ? T.primary
                                : T.surfaceRaised,
                            shape: BoxShape.circle,
                            boxShadow: T.raisedSm(),
                          ),
                          child: value
                              ? Icon(
                                  Icons.check_rounded,
                                  size: 16,
                                  color: T.inkInverse,
                                )
                              : null,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
