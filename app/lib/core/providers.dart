import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'alerts/alert_engine.dart';
import 'auth/auth_service.dart';
import 'background/background_controller.dart';
import 'ble/ble_service.dart';
import 'db/database.dart';
import 'db/repositories.dart';
import 'export/health_report_service.dart';
import 'llm/llm_service.dart';
import 'ml/anomaly_detector.dart';
import 'ml/baseline_service.dart';
import 'ml/feature_extractor.dart';
import 'notifications/notifications_service.dart';
import 'profile/settings_store.dart';

/// All service-level providers in one place. Feature code reads from these.

// ─── infrastructure ────────────────────────────────────────────────────────

final sharedPrefsProvider = FutureProvider<SharedPreferences>((ref) async {
  return SharedPreferences.getInstance();
});

final settingsProvider = Provider<SettingsStore>((ref) {
  final prefs = ref.watch(sharedPrefsProvider).requireValue;
  return SettingsStore(prefs);
});

final secureStorageProvider = Provider<FlutterSecureStorage>((ref) {
  return const FlutterSecureStorage();
});

final dbProvider = Provider<AppDb>((ref) {
  final db = AppDb();
  ref.onDispose(db.close);
  return db;
});

// ─── repositories ──────────────────────────────────────────────────────────

final sensorRepoProvider = Provider<SensorRepo>(
  (ref) => SensorRepo(ref.watch(dbProvider)),
);
final featureRepoProvider = Provider<FeatureRepo>(
  (ref) => FeatureRepo(ref.watch(dbProvider)),
);
final anomalyRepoProvider = Provider<AnomalyRepo>(
  (ref) => AnomalyRepo(ref.watch(dbProvider)),
);
final profileRepoProvider = Provider<ProfileRepo>(
  (ref) => ProfileRepo(ref.watch(dbProvider)),
);
final deviceRepoProvider = Provider<DeviceRepo>(
  (ref) => DeviceRepo(ref.watch(dbProvider)),
);
final chatRepoProvider = Provider<ChatRepo>(
  (ref) => ChatRepo(ref.watch(dbProvider)),
);

// ─── services ──────────────────────────────────────────────────────────────

final authServiceProvider = Provider<AuthService>(
  (ref) => AuthService(ref.watch(secureStorageProvider)),
);

final notificationsServiceProvider = Provider<NotificationsService>(
  (ref) => NotificationsService(),
);

final featureExtractorProvider = Provider<FeatureExtractor>(
  (ref) => FeatureExtractor(),
);

final baselineServiceProvider = Provider<BaselineService>(
  (ref) => BaselineService(ref.watch(dbProvider)),
);

final anomalyDetectorProvider = Provider<AnomalyDetector>(
  (ref) => AnomalyDetector(),
);

final alertEngineProvider = Provider<AlertEngine>(
  (ref) => AlertEngine(
    ref.watch(anomalyRepoProvider),
    ref.watch(baselineServiceProvider),
    ref.watch(notificationsServiceProvider),
  ),
);

final bleServiceProvider = Provider<BleService>((ref) {
  final svc = BleService(
    settings: ref.watch(settingsProvider),
    sensorRepo: ref.watch(sensorRepoProvider),
    featureRepo: ref.watch(featureRepoProvider),
    deviceRepo: ref.watch(deviceRepoProvider),
    featureExtractor: ref.watch(featureExtractorProvider),
    baseline: ref.watch(baselineServiceProvider),
    detector: ref.watch(anomalyDetectorProvider),
    alerts: ref.watch(alertEngineProvider),
  );
  ref.onDispose(svc.dispose);
  return svc;
});

final llmServiceProvider = Provider<LlmService>(
  (ref) => LlmService(
    ble: ref.watch(bleServiceProvider),
    sensorRepo: ref.watch(sensorRepoProvider),
    anomalyRepo: ref.watch(anomalyRepoProvider),
    profileRepo: ref.watch(profileRepoProvider),
  ),
);

final backgroundProvider = Provider<BackgroundController>(
  (ref) => BackgroundController(),
);

final healthReportServiceProvider = Provider<HealthReportService>(
  (ref) => HealthReportService(
    sensorRepo: ref.watch(sensorRepoProvider),
    featureRepo: ref.watch(featureRepoProvider),
    anomalyRepo: ref.watch(anomalyRepoProvider),
    profileRepo: ref.watch(profileRepoProvider),
  ),
);

// ─── session-scoped UI state ───────────────────────────────────────────────

/// Whether the app is currently locked (post-PIN/biometric required).
class IsLockedNotifier extends Notifier<bool> {
  @override
  bool build() => true;
  void unlock() => state = false;
  void lock() => state = true;
}

final isLockedProvider = NotifierProvider<IsLockedNotifier, bool>(
  IsLockedNotifier.new,
);

/// Currently selected bottom-nav tab index (0..4).
class ShellTabNotifier extends Notifier<int> {
  @override
  int build() => 0;
  set index(int v) => state = v;
}

final shellTabProvider = NotifierProvider<ShellTabNotifier, int>(
  ShellTabNotifier.new,
);

/// Live unread alert count for the bottom-nav badge.
final unreadAlertCountProvider = StreamProvider<int>(
  (ref) => ref.watch(anomalyRepoProvider).watchUnreadCount(),
);
