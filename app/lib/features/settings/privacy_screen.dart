import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/router.dart';
import '../../core/providers.dart';
import '../../core/theme/tokens.dart';
import '../../shared/widgets/widgets.dart';

class PrivacyScreen extends ConsumerWidget {
  const PrivacyScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return NeuScaffold(
      title: 'Privacy',
      showBack: true,
      onBack: () => context.go(Routes.settings),
      scrollable: true,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          NeuCard(
            color: T.primarySoft,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.shield_rounded, size: T.iconXl, color: T.primary),
                const SizedBox(height: T.space3),
                Text(
                  'Everything stays on this phone',
                  style: T.h2.copyWith(color: T.primary),
                ),
                const SizedBox(height: T.space2),
                Text(
                  'Your readings, alert history, profile, chat messages, and '
                  'usual-pattern learning are stored locally on this device. '
                  'They are never uploaded to any server.',
                  style: T.body.copyWith(color: T.primary),
                ),
              ],
            ),
          ),
          const SizedBox(height: T.space5),
          NeuListGroup(
            children: [
              const NeuListTile(
                icon: Icons.cloud_off_rounded,
                title: 'No account required',
                subtitle: 'Pulse Edge keeps your readings on your phone.',
              ),
              const NeuListTile(
                icon: Icons.psychology_rounded,
                title: 'Private assistant',
                subtitle:
                    'The assistant explains your readings using data on this phone.',
              ),
              const NeuListTile(
                icon: Icons.bluetooth_rounded,
                title: 'Bluetooth only',
                subtitle: 'The wearable connects directly to your phone.',
              ),
              NeuListTile(
                icon: Icons.ios_share_rounded,
                title: 'User-controlled exports',
                subtitle:
                    'Health reports are created locally and only leave the app when you share them.',
              ),
            ],
          ),
          const SizedBox(height: T.space5),
          NeuButton(
            label: 'Erase everything on this device',
            icon: Icons.delete_forever_rounded,
            variant: NeuButtonVariant.danger,
            onPressed: () => _confirmWipe(context, ref),
          ),
        ],
      ),
    );
  }

  Future<void> _confirmWipe(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: T.surfaceRaised,
        title: const Text('Erase everything?'),
        content: const Text(
          'This deletes your profile, usual-pattern learning, alert history, '
          'chats, and local settings. The app will return to first-launch state.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            style: TextButton.styleFrom(foregroundColor: T.danger),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Erase'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    await ref.read(authServiceProvider).wipe();
    await ref.read(settingsProvider).wipe();
    if (!context.mounted) return;
    context.go(Routes.splash);
  }
}
