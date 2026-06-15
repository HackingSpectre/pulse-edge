import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/router.dart';
import '../../core/db/database.dart';
import '../../core/providers.dart';
import '../../core/theme/tokens.dart';
import '../../shared/widgets/widgets.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileAsync = ref.watch(_profileStreamProvider);
    return NeuScaffold(
      title: 'Settings',
      scrollable: true,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          NeuCard(
            onTap: () => context.go(Routes.settingsProfile),
            child: Row(
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: T.primarySoft,
                    shape: BoxShape.circle,
                  ),
                  alignment: Alignment.center,
                  child: Icon(Icons.person_rounded, size: 28, color: T.primary),
                ),
                const SizedBox(width: T.space4),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        profileAsync.value?.name ?? 'Set up your profile',
                        style: T.h3,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        profileAsync.value?.username == null
                            ? 'Used only on this device'
                            : '@${profileAsync.value!.username}',
                        style: T.caption,
                      ),
                    ],
                  ),
                ),
                Icon(Icons.chevron_right_rounded, color: T.inkMuted),
              ],
            ),
          ),
          const SizedBox(height: T.space5),
          Text('APP', style: T.label),
          const SizedBox(height: T.space2),
          NeuListGroup(
            children: [
              NeuListTile(
                icon: Icons.bluetooth_rounded,
                title: 'Wearable',
                subtitle: 'Pair, disconnect, and check fit',
                onTap: () => context.go(Routes.settingsDevice),
              ),
              NeuListTile(
                icon: Icons.health_and_safety_rounded,
                iconColor: T.info,
                title: 'Health guidance',
                subtitle: 'How alerts and assistant replies are explained',
                onTap: () => context.go(Routes.settingsModel),
              ),
              NeuListTile(
                icon: Icons.auto_graph_rounded,
                iconColor: T.warning,
                title: 'Usual patterns',
                subtitle: 'Review progress or reset learning',
                onTap: () => context.go(Routes.settingsCalibration),
              ),
            ],
          ),
          const SizedBox(height: T.space5),
          Text('PRIVACY & DATA', style: T.label),
          const SizedBox(height: T.space2),
          NeuListGroup(
            children: [
              NeuListTile(
                icon: Icons.shield_rounded,
                iconColor: T.success,
                title: 'Privacy',
                subtitle: 'How your data is stored',
                onTap: () => context.go(Routes.settingsPrivacy),
              ),
              NeuListTile(
                icon: Icons.ios_share_rounded,
                iconColor: T.info,
                title: 'Health report',
                subtitle: 'Share or save a summary for your doctor',
                onTap: () => context.go(Routes.healthReport),
              ),
              NeuListTile(
                icon: Icons.lock_rounded,
                title: 'Password',
                subtitle: 'Set or update your app PIN',
                onTap: () => context.go(Routes.settingsSecurity),
              ),
              NeuListTile(
                icon: Icons.info_outline_rounded,
                title: 'About',
                subtitle: 'App information',
                onTap: () => context.go(Routes.settingsAbout),
              ),
            ],
          ),
          const SizedBox(height: T.space5),
        ],
      ),
    );
  }
}

final _profileStreamProvider = StreamProvider<Profile?>(
  (ref) => ref.watch(profileRepoProvider).watch(),
);
