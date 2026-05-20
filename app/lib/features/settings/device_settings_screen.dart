import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../app/router.dart';
import '../../core/ble/connection_state.dart';
import '../../core/db/database.dart';
import '../../core/providers.dart';
import '../../core/theme/tokens.dart';
import '../../shared/widgets/widgets.dart';

class DeviceSettingsScreen extends ConsumerWidget {
  const DeviceSettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ble = ref.watch(bleServiceProvider);
    final repo = ref.watch(deviceRepoProvider);
    return NeuScaffold(
      title: 'Wearable',
      showBack: true,
      onBack: () => context.go(Routes.settings),
      scrollable: true,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          StreamBuilder<BleStatus>(
            stream: ble.status$,
            initialData: ble.status,
            builder: (context, snap) {
              final s = snap.data!;
              return NeuCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          s.isConnected
                              ? Icons.bluetooth_connected_rounded
                              : Icons.bluetooth_disabled_rounded,
                          color: s.isConnected ? T.success : T.inkMuted,
                        ),
                        const SizedBox(width: T.space3),
                        Expanded(
                          child: Text(
                            s.deviceName ?? 'No device paired',
                            style: T.h3,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: T.space3),
                    if (s.firmwareVersion != null)
                      _kv('Firmware', s.firmwareVersion!),
                    if (s.batteryPct != null)
                      _kv('Battery', '${s.batteryPct}%'),
                    if (s.sensorOk != null)
                      _kv('Sensors', s.sensorOk! ? 'OK' : 'Check wiring'),
                    if (s.contactOk != null)
                      _kv(
                        'Wrist contact',
                        s.contactOk! ? 'Good' : 'Adjust fit',
                      ),
                    if (s.demo) _kv('Mode', 'Demo / synthetic data'),
                  ],
                ),
              );
            },
          ),
          const SizedBox(height: T.space4),
          Row(
            children: [
              Expanded(
                child: NeuButton(
                  label: 'Restart demo',
                  icon: Icons.refresh_rounded,
                  onPressed: () => ble.startDemo(),
                ),
              ),
              const SizedBox(width: T.space3),
              Expanded(
                child: NeuButton(
                  label: 'Disconnect',
                  icon: Icons.bluetooth_disabled_rounded,
                  variant: NeuButtonVariant.subtle,
                  onPressed: () => ble.stop(),
                ),
              ),
            ],
          ),
          const SizedBox(height: T.space5),
          StreamBuilder<Device?>(
            stream: repo.watchPaired(),
            builder: (context, snap) {
              final d = snap.data;
              if (d == null) {
                return NeuCard(
                  child: Column(
                    children: [
                      Icon(
                        Icons.devices_rounded,
                        size: T.iconXl,
                        color: T.inkMuted,
                      ),
                      const SizedBox(height: T.space3),
                      Text(
                        'No device remembered yet',
                        style: T.caption.copyWith(color: T.inkMuted),
                      ),
                    ],
                  ),
                );
              }
              final paired = DateFormat.yMMMd().add_jm().format(
                DateTime.fromMillisecondsSinceEpoch(d.pairedAtMs),
              );
              return NeuCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Remembered device'.toUpperCase(), style: T.label),
                    const SizedBox(height: T.space3),
                    _kv('Name', d.name),
                    _kv('Hardware ID', d.hardwareId),
                    _kv('Paired', paired),
                    const SizedBox(height: T.space4),
                    NeuButton(
                      label: 'Forget device',
                      icon: Icons.delete_outline_rounded,
                      variant: NeuButtonVariant.danger,
                      onPressed: () async {
                        await ble.stop();
                        await repo.forget();
                      },
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _kv(String k, String v) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 4),
    child: Row(
      children: [
        Text(k, style: T.caption),
        const Spacer(),
        Text(v, style: T.body.copyWith(fontFamily: T.fontMono, fontSize: 13)),
      ],
    ),
  );
}
