import 'package:shared_preferences/shared_preferences.dart';

/// Persistent app-level flags. Profile-level data lives in drift; this is
/// for non-PII app preferences only (onboarding completed, demo mode, etc.).
class SettingsStore {
  SettingsStore(this._prefs);
  final SharedPreferences _prefs;

  static const _kOnboardingComplete = 'onboarding_complete';
  static const _kDemoMode = 'demo_mode_enabled';
  static const _kAutoLockMinutes = 'auto_lock_minutes';
  static const _kCalibrationCompleteMs = 'calibration_complete_ms';

  bool get onboardingComplete => _prefs.getBool(_kOnboardingComplete) ?? false;
  Future<void> setOnboardingComplete(bool v) => _prefs.setBool(_kOnboardingComplete, v);

  bool get demoMode => _prefs.getBool(_kDemoMode) ?? true;
  Future<void> setDemoMode(bool v) => _prefs.setBool(_kDemoMode, v);

  int get autoLockMinutes => _prefs.getInt(_kAutoLockMinutes) ?? 2;
  Future<void> setAutoLockMinutes(int v) => _prefs.setInt(_kAutoLockMinutes, v);

  int? get calibrationCompleteMs => _prefs.getInt(_kCalibrationCompleteMs);
  Future<void> setCalibrationComplete() =>
      _prefs.setInt(_kCalibrationCompleteMs, DateTime.now().millisecondsSinceEpoch);

  Future<void> wipe() async {
    final keys = _prefs.getKeys().toSet();
    for (final k in keys) {
      await _prefs.remove(k);
    }
  }
}
