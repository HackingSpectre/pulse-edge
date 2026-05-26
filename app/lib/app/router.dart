import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../core/providers.dart';
import '../features/alerts/alert_detail_screen.dart';
import '../features/alerts/alerts_screen.dart';
import '../features/auth/lock_screen.dart';
import '../features/chat/chat_screen.dart';
import '../features/dashboard/dashboard_screen.dart';
import '../features/history/history_screen.dart';
import '../features/onboarding/onboarding_flow.dart';
import '../features/onboarding/splash_screen.dart';
import '../features/settings/about_screen.dart';
import '../features/settings/calibration_screen.dart';
import '../features/settings/device_settings_screen.dart';
import '../features/settings/model_settings_screen.dart';
import '../features/settings/privacy_screen.dart';
import '../features/settings/profile_edit_screen.dart';
import '../features/settings/security_screen.dart';
import '../features/settings/settings_screen.dart';
import '../features/shell/main_shell.dart';

/// Route names used across the app.
class Routes {
  static const splash = '/';
  static const onboarding = '/onboarding';
  static const lock = '/lock';
  static const dashboard = '/home';
  static const history = '/history';
  static const alerts = '/alerts';
  static const alertDetail = '/alerts/:id';
  static const chat = '/chat';
  static const settings = '/settings';
  static const settingsProfile = '/settings/profile';
  static const settingsDevice = '/settings/device';
  static const settingsModel = '/settings/model';
  static const settingsPrivacy = '/settings/privacy';
  static const settingsSecurity = '/settings/security';
  static const settingsCalibration = '/settings/calibration';
  static const settingsAbout = '/settings/about';
}

final routerProvider = Provider<GoRouter>((ref) {
  final settings = ref.watch(settingsProvider);

  return GoRouter(
    initialLocation: Routes.splash,
    debugLogDiagnostics: false,
    redirect: (context, state) {
      final loc = state.matchedLocation;
      // Splash and onboarding manage their own progression.
      if (loc == Routes.splash) return null;
      if (loc.startsWith(Routes.onboarding)) return null;

      // Force onboarding before anything else.
      if (!settings.onboardingComplete) {
        return Routes.onboarding;
      }

      // Lock gate.
      final locked = ref.read(isLockedProvider);
      if (locked && loc != Routes.lock) {
        return Routes.lock;
      }
      if (!locked && loc == Routes.lock) {
        return Routes.dashboard;
      }
      return null;
    },
    routes: [
      GoRoute(path: Routes.splash, builder: (_, _) => const SplashScreen()),
      GoRoute(
        path: Routes.onboarding,
        builder: (_, _) => const OnboardingFlow(),
      ),
      GoRoute(path: Routes.lock, builder: (_, _) => const LockScreen()),
      ShellRoute(
        builder: (context, state, child) => MainShell(child: child),
        routes: [
          GoRoute(
            path: Routes.dashboard,
            builder: (_, _) => const DashboardScreen(),
          ),
          GoRoute(
            path: Routes.history,
            builder: (_, _) => const HistoryScreen(),
          ),
          GoRoute(path: Routes.alerts, builder: (_, _) => const AlertsScreen()),
          GoRoute(
            path: Routes.alertDetail,
            builder: (_, state) =>
                AlertDetailScreen(id: state.pathParameters['id']!),
          ),
          GoRoute(path: Routes.chat, builder: (_, _) => const ChatScreen()),
          GoRoute(
            path: Routes.settings,
            builder: (_, _) => const SettingsScreen(),
          ),
          GoRoute(
            path: Routes.settingsProfile,
            builder: (_, _) => const ProfileEditScreen(),
          ),
          GoRoute(
            path: Routes.settingsDevice,
            builder: (_, _) => const DeviceSettingsScreen(),
          ),
          GoRoute(
            path: Routes.settingsModel,
            builder: (_, _) => const ModelSettingsScreen(),
          ),
          GoRoute(
            path: Routes.settingsPrivacy,
            builder: (_, _) => const PrivacyScreen(),
          ),
          GoRoute(
            path: Routes.settingsSecurity,
            builder: (_, _) => const SecurityScreen(),
          ),
          GoRoute(
            path: Routes.settingsCalibration,
            builder: (_, _) => const CalibrationScreen(),
          ),
          GoRoute(
            path: Routes.settingsAbout,
            builder: (_, _) => const AboutScreen(),
          ),
        ],
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      body: Center(child: Text('Route not found: ${state.matchedLocation}')),
    ),
  );
});
