import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../../core/theme/tokens.dart';
import '../../../shared/widgets/widgets.dart';

class StepPermissions extends StatefulWidget {
  const StepPermissions({super.key});

  @override
  State<StepPermissions> createState() => _StepPermissionsState();
}

class _StepPermissionsState extends State<StepPermissions> {
  bool _ble = false;
  bool _notifications = false;

  Future<void> _requestBle() async {
    final ok = await [
      Permission.bluetoothScan,
      Permission.bluetoothConnect,
      Permission.location,
    ].request();
    setState(() {
      _ble = ok.values.every((s) => s.isGranted || s.isLimited);
    });
  }

  Future<void> _requestNotifications() async {
    final s = await Permission.notification.request();
    setState(() => _notifications = s.isGranted);
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: T.space5),
          Text('Permissions', style: T.h1),
          const SizedBox(height: T.space2),
          Text(
            'Pulse Edge needs two permissions to do its job. You can revoke '
            'either at any time from your phone settings.',
            style: T.bodySoft,
          ),
          const SizedBox(height: T.space6),
          _PermRow(
            icon: Icons.bluetooth_rounded,
            color: T.info,
            title: 'Bluetooth',
            subtitle: 'Connect to your wearable.',
            granted: _ble,
            onTap: _requestBle,
          ),
          const SizedBox(height: T.space4),
          _PermRow(
            icon: Icons.notifications_rounded,
            color: T.warning,
            title: 'Notifications',
            subtitle: 'Show alerts when something looks unusual.',
            granted: _notifications,
            onTap: _requestNotifications,
          ),
          const SizedBox(height: T.space5),
          NeuCard(
            color: T.primarySoft,
            child: Row(
              children: [
                const Icon(Icons.shield_rounded, color: T.primary),
                const SizedBox(width: T.space3),
                Expanded(
                  child: Text(
                    'No internet, microphone, camera, or location-tracking '
                    'permissions are required.',
                    style: T.caption.copyWith(color: T.primary),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: T.space5),
        ],
      ),
    );
  }
}

class _PermRow extends StatelessWidget {
  const _PermRow({
    required this.icon,
    required this.color,
    required this.title,
    required this.subtitle,
    required this.granted,
    required this.onTap,
  });

  final IconData icon;
  final Color color;
  final String title;
  final String subtitle;
  final bool granted;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return NeuCard(
      onTap: granted ? null : onTap,
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.14),
              borderRadius: T.brSm,
            ),
            child: Icon(icon, size: T.iconMd, color: color),
          ),
          const SizedBox(width: T.space4),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: T.h3),
                const SizedBox(height: T.space1),
                Text(subtitle, style: T.caption),
              ],
            ),
          ),
          const SizedBox(width: T.space3),
          AnimatedSwitcher(
            duration: T.motionBase,
            child: granted
                ? const _Granted(key: ValueKey(true))
                : NeuButton(
                    key: const ValueKey(false),
                    label: 'Allow',
                    onPressed: onTap,
                    size: NeuSize.sm,
                  ),
          ),
        ],
      ),
    );
  }
}

class _Granted extends StatelessWidget {
  const _Granted({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: T.space3,
        vertical: T.space2,
      ),
      decoration: BoxDecoration(
        color: T.successSoft,
        borderRadius: T.brPill,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.check_rounded, size: T.iconSm, color: T.success),
          const SizedBox(width: T.space2),
          Text('Granted',
              style: T.caption.copyWith(
                color: T.success,
                fontWeight: FontWeight.w700,
              )),
        ],
      ),
    );
  }
}
