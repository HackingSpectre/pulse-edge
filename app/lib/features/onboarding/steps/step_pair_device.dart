import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/ble/connection_state.dart';
import '../../../core/providers.dart';
import '../../../core/theme/tokens.dart';
import '../../../shared/widgets/widgets.dart';

class StepPairDevice extends ConsumerStatefulWidget {
  const StepPairDevice({super.key});

  @override
  ConsumerState<StepPairDevice> createState() => _StepPairDeviceState();
}

class _StepPairDeviceState extends ConsumerState<StepPairDevice> {
  final _results = <ScanResult>[];
  bool _scanning = false;
  bool _demoStarted = false;

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
    } catch (e) {
      // Surface scan failures via SnackBar so the demo flow still works.
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Scan failed: $e')));
    }
    if (mounted) setState(() => _scanning = false);
  }

  Future<void> _connect(ScanResult r) async {
    try {
      await ref.read(bleServiceProvider).connect(r.device);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Connection failed: $e')));
    }
  }

  Future<void> _useDemo() async {
    await ref.read(bleServiceProvider).startDemo();
    setState(() => _demoStarted = true);
  }

  @override
  Widget build(BuildContext context) {
    final ble = ref.watch(bleServiceProvider);
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: T.space5),
          Text('Pair your wearable', style: T.h1),
          const SizedBox(height: T.space2),
          Text(
            "Power on the Pulse Edge wearable and tap Scan. No wearable yet? "
            'Use the built-in demo source to explore the app with synthetic '
            'data.',
            style: T.bodySoft,
          ),
          const SizedBox(height: T.space6),
          Row(
            children: [
              Expanded(
                child: NeuButton(
                  label: _scanning ? 'Scanning…' : 'Scan',
                  icon: Icons.bluetooth_searching_rounded,
                  loading: _scanning,
                  onPressed: _scanning ? null : _scan,
                ),
              ),
              const SizedBox(width: T.space3),
              Expanded(
                child: NeuButton(
                  label: _demoStarted ? 'Demo on' : 'Use demo',
                  icon: Icons.science_rounded,
                  variant: NeuButtonVariant.subtle,
                  onPressed: _useDemo,
                ),
              ),
            ],
          ),
          const SizedBox(height: T.space5),
          StreamBuilder<BleStatus>(
            stream: ble.status$,
            initialData: ble.status,
            builder: (context, snap) {
              final status = snap.data ?? BleStatus.idle;
              if (status.isConnected) {
                return NeuCard(
                  color: T.successSoft,
                  child: Row(
                    children: [
                      const Icon(Icons.check_circle_rounded, color: T.success),
                      const SizedBox(width: T.space3),
                      Expanded(
                        child: Text(
                          'Connected to ${status.deviceName ?? 'wearable'}'
                          '${status.demo ? ' (demo)' : ''}',
                          style: T.bodyStrong,
                        ),
                      ),
                    ],
                  ),
                );
              }
              if (_results.isEmpty) {
                return NeuCard(
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
                            : 'Nothing found yet — keep the wearable powered on and tap Scan.',
                        style: T.caption,
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                );
              }
              return Column(
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
                          const Icon(Icons.bluetooth_rounded, color: T.primary),
                          const SizedBox(width: T.space4),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(name, style: T.bodyStrong),
                                Text(r.device.remoteId.str, style: T.caption),
                              ],
                            ),
                          ),
                          Text('${r.rssi} dBm', style: T.caption),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              );
            },
          ),
          const SizedBox(height: T.space5),
        ],
      ),
    );
  }
}
