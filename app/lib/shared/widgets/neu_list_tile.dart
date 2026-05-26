import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/theme/tokens.dart';
import 'neu_surface.dart';

/// Settings/list row inside a [NeuCard]. Tap target is row-wide.
class NeuListTile extends StatelessWidget {
  const NeuListTile({
    super.key,
    this.icon,
    this.iconColor,
    required this.title,
    this.subtitle,
    this.trailing,
    this.onTap,
    this.padding = const EdgeInsets.symmetric(
      horizontal: T.space4,
      vertical: T.space3,
    ),
  });

  final IconData? icon;
  final Color? iconColor;
  final String title;
  final String? subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    final body = Padding(
      padding: padding,
      child: Row(
        children: [
          if (icon != null) ...[
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: (iconColor ?? T.primary).withValues(alpha: 0.12),
                borderRadius: T.brSm,
              ),
              child: Icon(icon, size: T.iconSm, color: iconColor ?? T.primary),
            ),
            const SizedBox(width: T.space4),
          ],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title,
                  style: T.bodyStrong,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    subtitle!,
                    style: T.caption,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ],
            ),
          ),
          if (trailing != null) ...[
            const SizedBox(width: T.space3),
            trailing!,
          ] else if (onTap != null) ...[
            const SizedBox(width: T.space3),
            Icon(
              Icons.chevron_right_rounded,
              color: T.inkMuted,
              size: T.iconSm,
            ),
          ],
        ],
      ),
    );
    if (onTap == null) return body;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          HapticFeedback.selectionClick();
          onTap!();
        },
        borderRadius: T.brSm,
        splashColor: T.primary.withValues(alpha: 0.06),
        highlightColor: Colors.transparent,
        child: body,
      ),
    );
  }
}

/// Hairline divider for use inside [NeuCard]s holding multiple [NeuListTile]s.
class NeuTileDivider extends StatelessWidget {
  const NeuTileDivider({super.key, this.indent = T.space4 + 36 + T.space4});
  final double indent;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(left: indent, right: T.space4),
      child: Divider(height: 1, thickness: 1, color: T.divider),
    );
  }
}

/// A column of [NeuListTile]s separated by [NeuTileDivider]s, all wrapped
/// in a single [NeuCard]. Use for grouped settings rows.
class NeuListGroup extends StatelessWidget {
  const NeuListGroup({super.key, required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final divided = <Widget>[];
    for (var i = 0; i < children.length; i++) {
      divided.add(children[i]);
      if (i < children.length - 1) divided.add(const NeuTileDivider());
    }
    return NeuSurface(
      depth: NeuDepth.raised,
      borderRadius: T.brLg,
      padding: const EdgeInsets.symmetric(vertical: T.space2),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: divided,
      ),
    );
  }
}
