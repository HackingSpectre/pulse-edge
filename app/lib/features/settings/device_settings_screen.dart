import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../app/router.dart';
import '../../core/ble/connection_state.dart';
import '../../core/db/database.dart';
import '../../core/providers.dart';
import '../../core/theme/tokens.dart';
import '../../shared/widgets/widgets.dart';

class DeviceSettingsScreen extends ConsumerStatefulWidget {
  const DeviceSettingsScreen({super.key});

  @override
  ConsumerState<DeviceSettingsScreen> createState() =>
      _DeviceSettingsScreenState();
}

class _DeviceSettingsScreenState extends ConsumerState<DeviceSettingsScreen> {
  final _results = <ScanResult>[];
  bool _scanning = false;

  Future<void> _scan() async {
    final ble = ref.read(bleServiceProvider);
    setState(() {
      _scanning = true;
      _results.clear();
    });
    try {
      await for (final r in ble.scan()) {
        if (!mounted) break;
        setState(() {
          _results
            ..clear()
            ..addAll(r);
        });
      }
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Could not scan. Check Bluetooth and try again.'),
        ),
      );
    }
    if (mounted) setState(() => _scanning = false);
  }

  Future<void> _connect(ScanResult r) async {
    try {
      await ref.read(bleServiceProvider).connect(r.device);
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Could not connect. Move closer and try again.'),
        ),
      );
    }
  }

  Future<void> _forgetDevice(Device d) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Forget device?'),
        content: Text(
          'This will disconnect ${d.name} and remove it from your phone. '
          'You can scan and pair again anytime.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Forget'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    final ble = ref.read(bleServiceProvider);
    final repo = ref.read(deviceRepoProvider);
    try {
      await ble.stop();
      await repo.forget();
      if (!mounted) return;
      setState(_results.clear);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Device forgotten.')));
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Could not forget this device right now.'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
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
                      _kv('Sensors', s.sensorOk! ? 'OK' : 'Check wearable'),
                    if (s.contactOk != null)
                      _kv(
                        'Wrist contact',
                        s.contactOk! ? 'Good' : 'Adjust fit',
                      ),
                  ],
                ),
              );
            },
          ),
          const SizedBox(height: T.space4),
          NeuButton(
            label: 'Disconnect',
            icon: Icons.bluetooth_disabled_rounded,
            variant: NeuButtonVariant.subtle,
            expanded: true,
            onPressed: () => ble.stop(),
          ),
          const SizedBox(height: T.space4),
          Row(
            children: [
              Expanded(
                child: NeuButton(
                  label: _scanning ? 'Scanning…' : 'Scan for devices',
                  icon: Icons.bluetooth_searching_rounded,
                  loading: _scanning,
                  onPressed: _scanning ? null : _scan,
                ),
              ),
            ],
          ),
          const SizedBox(height: T.space4),
          if (_results.isEmpty)
            NeuCard(
              child: Column(
                children: [
                  Icon(
                    Icons.devices_other_rounded,
                    size: T.iconXl,
                    color: T.inkMuted,
                  ),
                  const SizedBox(height: T.space3),
                  Text(
                    _scanning
                        ? 'Looking for PulseEdge nearby…'
                        : 'No devices found yet - tap Scan to try again.',
                    style: T.caption,
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            )
          else
            Column(
              children: _results.map((r) {
                final name = r.advertisementData.advName.isNotEmpty
                    ? r.advertisementData.advName
                    : (r.device.platformName.isEmpty
                          ? 'Pulse Edge'
                          : r.device.platformName);
                return Padding(
                  padding: const EdgeInsets.only(bottom: T.space3),
                  child: NeuCard(
                    onTap: () => _connect(r),
                    child: Row(
                      children: [
                        Icon(Icons.bluetooth_rounded, color: T.primary),
                        const SizedBox(width: T.space4),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(name, style: T.bodyStrong),
                              Text('Tap to connect', style: T.caption),
                            ],
                          ),
                        ),
                        Text(_signalLabel(r.rssi), style: T.caption),
                      ],
                    ),
                  ),
                );
              }).toList(),
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
                    _kv('Paired', paired),
                    const SizedBox(height: T.space4),
                    NeuButton(
                      label: 'Forget device',
                      icon: Icons.delete_outline_rounded,
                      variant: NeuButtonVariant.danger,
                      onPressed: () => _forgetDevice(d),
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

  String _signalLabel(int rssi) {
    if (rssi >= -60) return 'Strong';
    if (rssi >= -75) return 'Good';
    return 'Weak';
  }
}
