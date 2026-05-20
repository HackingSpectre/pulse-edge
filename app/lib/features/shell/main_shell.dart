import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/router.dart';
import '../../core/providers.dart';
import '../../shared/widgets/widgets.dart';

/// Bottom-nav shell that wraps the five primary tabs.
class MainShell extends ConsumerWidget {
  const MainShell({super.key, required this.child});
  final Widget child;

  static const _routes = [
    Routes.dashboard,
    Routes.history,
    Routes.alerts,
    Routes.chat,
    Routes.settings,
  ];

  int _indexFor(String location) {
    if (location.startsWith(Routes.dashboard)) return 0;
    if (location.startsWith(Routes.history)) return 1;
    if (location.startsWith(Routes.alerts)) return 2;
    if (location.startsWith(Routes.chat)) return 3;
    if (location.startsWith(Routes.settings)) return 4;
    return 0;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final location = GoRouterState.of(context).matchedLocation;
    final index = _indexFor(location);
    final unread = ref.watch(unreadAlertCountProvider).value ?? 0;

    final items = <NeuNavItem>[
      const NeuNavItem(
        icon: Icons.favorite_border_rounded,
        activeIcon: Icons.favorite_rounded,
        label: 'Home',
      ),
      const NeuNavItem(
        icon: Icons.show_chart_outlined,
        activeIcon: Icons.show_chart_rounded,
        label: 'History',
      ),
      NeuNavItem(
        icon: Icons.notifications_none_rounded,
        activeIcon: Icons.notifications_active_rounded,
        label: 'Alerts',
        badge: unread,
      ),
      const NeuNavItem(
        icon: Icons.chat_bubble_outline_rounded,
        activeIcon: Icons.chat_bubble_rounded,
        label: 'Chat',
      ),
      const NeuNavItem(
        icon: Icons.settings_outlined,
        activeIcon: Icons.settings_rounded,
        label: 'Settings',
      ),
    ];

    return Scaffold(
      body: child,
      bottomNavigationBar: NeuBottomNav(
        items: items,
        currentIndex: index,
        onTap: (i) {
          if (i == index) return;
          context.go(_routes[i]);
        },
      ),
    );
  }
}
