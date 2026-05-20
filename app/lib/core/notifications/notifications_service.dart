import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import '../utils/logger.dart';

/// Wrapper around flutter_local_notifications. Three channels — HIGH, MEDIUM,
/// LOW — so users can mute MEDIUM/LOW from system settings without missing
/// HIGH severity alerts.
class NotificationsService {
  NotificationsService();

  final _plugin = FlutterLocalNotificationsPlugin();
  bool _initialized = false;

  static const _highChannel = AndroidNotificationChannel(
    'pulse_edge_high',
    'High severity alerts',
    description: 'Alerts that may need urgent attention',
    importance: Importance.high,
    enableVibration: true,
    playSound: true,
  );
  static const _mediumChannel = AndroidNotificationChannel(
    'pulse_edge_medium',
    'Medium severity alerts',
    description: 'Pattern anomalies that may be worth reviewing',
    importance: Importance.defaultImportance,
  );
  static const _lowChannel = AndroidNotificationChannel(
    'pulse_edge_low',
    'Background reminders',
    description: 'Calibration nudges, charging reminders, etc.',
    importance: Importance.low,
  );

  Future<void> init() async {
    if (_initialized) return;
    const settings = InitializationSettings(
      android: AndroidInitializationSettings('@mipmap/ic_launcher'),
    );
    await _plugin.initialize(settings: settings);
    final android = _plugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    await android?.createNotificationChannel(_highChannel);
    await android?.createNotificationChannel(_mediumChannel);
    await android?.createNotificationChannel(_lowChannel);
    await android?.requestNotificationsPermission();
    _initialized = true;
  }

  Future<void> showHighAlert({
    required String title,
    required String body,
    required String anomalyId,
  }) async {
    await _ensureInit();
    await _plugin.show(
      id: anomalyId.hashCode & 0x7FFFFFFF,
      title: title,
      body: body,
      notificationDetails: const NotificationDetails(
        android: AndroidNotificationDetails(
          'pulse_edge_high',
          'High severity alerts',
          importance: Importance.high,
          priority: Priority.high,
          icon: '@mipmap/ic_launcher',
          category: AndroidNotificationCategory.alarm,
          ongoing: false,
          autoCancel: true,
        ),
      ),
      payload: 'alert:$anomalyId',
    );
  }

  Future<void> showMediumAlert({
    required String title,
    required String body,
    required String anomalyId,
  }) async {
    await _ensureInit();
    await _plugin.show(
      id: anomalyId.hashCode & 0x7FFFFFFF,
      title: title,
      body: body,
      notificationDetails: const NotificationDetails(
        android: AndroidNotificationDetails(
          'pulse_edge_medium',
          'Medium severity alerts',
          importance: Importance.defaultImportance,
          priority: Priority.defaultPriority,
          icon: '@mipmap/ic_launcher',
        ),
      ),
      payload: 'alert:$anomalyId',
    );
  }

  Future<void> _ensureInit() async {
    if (!_initialized) {
      try {
        await init();
      } catch (e) {
        log.e('Notification init failed', error: e);
      }
    }
  }
}
