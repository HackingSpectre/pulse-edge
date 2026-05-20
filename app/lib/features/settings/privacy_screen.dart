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
                const Icon(Icons.shield_rounded,
                    size: T.iconXl, color: T.primary),
                const SizedBox(height: T.space3),
                Text('Everything stays on this phone',
                    style: T.h2.copyWith(color: T.primary)),
                const SizedBox(height: T.space2),
                Text(
                  'Your sensor data, anomaly history, profile, chat messages, '
                  'and personal baseline live in an encrypted database on this '
                  'device. They are never uploaded to any server.',
                  style: T.body.copyWith(color: T.primary),
                ),
              ],
            ),
          ),
          const SizedBox(height: T.space5),
          NeuListGroup(children: [
            const NeuListTile(
              icon: Icons.cloud_off_rounded,
              title: 'No backend',
              subtitle: 'Pulse Edge does not run any servers.',
            ),
            const NeuListTile(
              icon: Icons.psychology_rounded,
              title: 'On-device assistant',
              subtitle:
                  'The AI chat is a small language model loaded into RAM on '
                  'your phone. Nothing leaves the device.',
            ),
            const NeuListTile(
              icon: Icons.bluetooth_rounded,
              title: 'Bluetooth only',
              subtitle: 'The wearable communicates over BLE — no Wi-Fi, no GSM.',
            ),
            NeuListTile(
              icon: Icons.download_for_offline_rounded,
              title: 'One-time downloads',
              subtitle:
                  'The only network use is the optional model download. After '
                  "that you can be permanently offline.",
            ),
          ]),
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
          'This deletes your profile, baseline, alert history, chats, and '
          'the AI model. The app will return to first-launch state.',
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
    await ref.read(modelDownloadProvider).delete();
    await ref.read(settingsProvider).wipe();
    if (!context.mounted) return;
    context.go(Routes.splash);
  }
}
