import 'package:flutter/foundation.dart';
import 'package:flutter_foreground_task/flutter_foreground_task.dart';

/// Wraps flutter_foreground_task to keep the BLE connection alive when
/// the app is backgrounded on Android 14+ (FGS type `connectedDevice`).
///
/// The actual BLE work runs in the main isolate; this service just owns
/// the persistent notification and foreground-service lifecycle.
class BackgroundController {
  BackgroundController() {
    _init();
  }

  void _init() {
    FlutterForegroundTask.init(
      androidNotificationOptions: AndroidNotificationOptions(
        channelId: 'pulse_edge_bg',
        channelName: 'Wearable connection',
        channelDescription:
            'Keeps the Pulse Edge wearable connected while the app is in the background.',
        channelImportance: NotificationChannelImportance.LOW,
        priority: NotificationPriority.LOW,
        showWhen: false,
      ),
      iosNotificationOptions: const IOSNotificationOptions(),
      foregroundTaskOptions: ForegroundTaskOptions(
        eventAction: ForegroundTaskEventAction.repeat(60000),
        autoRunOnBoot: false,
        autoRunOnMyPackageReplaced: false,
        allowWakeLock: true,
        allowWifiLock: false,
      ),
    );
  }

  Future<void> start({required String deviceName}) async {
    if (!await FlutterForegroundTask.isRunningService) {
      await FlutterForegroundTask.startService(
        notificationTitle: 'Pulse Edge connected',
        notificationText: 'Monitoring $deviceName in the background',
        callback: _bgEntryPoint,
      );
    } else {
      await FlutterForegroundTask.updateService(
        notificationText: 'Monitoring $deviceName in the background',
      );
    }
  }

  Future<void> stop() async {
    if (await FlutterForegroundTask.isRunningService) {
      await FlutterForegroundTask.stopService();
    }
  }
}

/// Entry point that the foreground task isolate runs. Kept minimal - BLE
/// stays in the main isolate, this just exists to satisfy the task lifecycle.
@pragma('vm:entry-point')
void _bgEntryPoint() {
  FlutterForegroundTask.setTaskHandler(_NoopHandler());
}

class _NoopHandler extends TaskHandler {
  @override
  Future<void> onStart(DateTime timestamp, TaskStarter starter) async {
    if (kDebugMode) {
      // ignore: avoid_print
      print('Pulse Edge background task started at $timestamp');
    }
  }

  @override
  void onRepeatEvent(DateTime timestamp) {}

  @override
  Future<void> onDestroy(DateTime timestamp, bool isTimeout) async {}
}
