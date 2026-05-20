import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/theme/tokens.dart';
import 'neu_surface.dart';

/// Status / filter chip with optional leading icon. Selected = sunken state.
class NeuChip extends StatelessWidget {
  const NeuChip({
    super.key,
    required this.label,
    this.icon,
    this.selected = false,
    this.onPressed,
    this.color,
    this.compact = false,
  });

  final String label;
  final IconData? icon;
  final bool selected;
  final VoidCallback? onPressed;
  final Color? color;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final accent = color ?? T.primary;
    final inkColor = selected ? accent : T.inkSoft;
    final padding = compact
        ? const EdgeInsets.symmetric(horizontal: T.space3, vertical: T.space2)
        : const EdgeInsets.symmetric(horizontal: T.space4, vertical: T.space3);
    final surface = NeuSurface(
      depth: selected ? NeuDepth.sunken : NeuDepth.raised,
      size: NeuSize.sm,
      borderRadius: T.brPill,
      padding: padding,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: T.iconXs, color: inkColor),
            const SizedBox(width: T.space2),
          ],
          Text(
            label,
            style: T.caption.copyWith(
              color: inkColor,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.4,
            ),
          ),
        ],
      ),
    );
    if (onPressed == null) return surface;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        HapticFeedback.selectionClick();
        onPressed!();
      },
      child: surface,
    );
  }
}

/// Severity badge — colored pill matching the neumorphic language. Used
/// across alert lists.
class NeuSeverityBadge extends StatelessWidget {
  const NeuSeverityBadge({
    super.key,
    required this.label,
    required this.color,
    this.icon,
  });

  final String label;
  final Color color;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: T.space3,
        vertical: T.space1 + 2,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.14),
        borderRadius: T.brPill,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: T.iconXs, color: color),
            const SizedBox(width: T.space1 + 2),
          ],
          Text(
            label,
            style: T.caption.copyWith(
              color: color,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.6,
            ),
          ),
        ],
      ),
    );
  }
}
