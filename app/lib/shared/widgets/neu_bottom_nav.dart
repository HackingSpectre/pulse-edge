import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/theme/tokens.dart';
import 'neu_surface.dart';

class NeuNavItem {
  const NeuNavItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
    this.badge,
  });
  final IconData icon;
  final IconData activeIcon;
  final String label;
  final int? badge;
}

/// 5-tab bottom nav rendered as a single floating neumorphic pill.
class NeuBottomNav extends StatelessWidget {
  const NeuBottomNav({
    super.key,
    required this.items,
    required this.currentIndex,
    required this.onTap,
  });

  final List<NeuNavItem> items;
  final int currentIndex;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          T.space4,
          T.space2,
          T.space4,
          T.space3,
        ),
        child: NeuSurface(
          depth: NeuDepth.raised,
          size: NeuSize.md,
          borderRadius: T.brPill,
          padding: const EdgeInsets.symmetric(
            horizontal: T.space2,
            vertical: T.space2,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              for (var i = 0; i < items.length; i++)
                Expanded(
                  child: _NavTab(
                    item: items[i],
                    selected: i == currentIndex,
                    onTap: () => onTap(i),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavTab extends StatelessWidget {
  const _NavTab({
    required this.item,
    required this.selected,
    required this.onTap,
  });

  final NeuNavItem item;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = selected ? T.primary : T.inkMuted;
    return Semantics(
      button: true,
      selected: selected,
      label: item.label,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () {
          HapticFeedback.selectionClick();
          onTap();
        },
        child: AnimatedContainer(
          duration: T.motionBase,
          curve: T.emphasized,
          padding: const EdgeInsets.symmetric(vertical: T.space3),
          decoration: BoxDecoration(
            borderRadius: T.brPill,
            color: selected
                ? T.primary.withValues(alpha: 0.10)
                : Colors.transparent,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Stack(
                clipBehavior: Clip.none,
                children: [
                  AnimatedSwitcher(
                    duration: T.motionFast,
                    child: Icon(
                      selected ? item.activeIcon : item.icon,
                      key: ValueKey(selected),
                      size: T.iconMd,
                      color: color,
                    ),
                  ),
                  if (item.badge != null && item.badge! > 0)
                    Positioned(
                      right: -8,
                      top: -4,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 5,
                          vertical: 1,
                        ),
                        decoration: BoxDecoration(
                          color: T.danger,
                          borderRadius: T.brPill,
                          border: Border.all(color: T.surface, width: 2),
                        ),
                        constraints: const BoxConstraints(
                          minWidth: 18,
                          minHeight: 18,
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          item.badge! > 9 ? '9+' : '${item.badge}',
                          style: TextStyle(
                            color: T.inkInverse,
                            fontFamily: T.fontBody,
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 2),
              AnimatedDefaultTextStyle(
                duration: T.motionFast,
                style: T.caption.copyWith(
                  color: color,
                  fontWeight: selected ? FontWeight.w700 : FontWeight.w400,
                  fontSize: 11,
                ),
                child: Text(item.label),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
