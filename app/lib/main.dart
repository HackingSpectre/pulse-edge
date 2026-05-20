import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app/app.dart';
import 'core/providers.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Lock to portrait — neumorphic layouts are tuned for narrow widths.
  await SystemChrome.setPreferredOrientations(const [
    DeviceOrientation.portraitUp,
  ]);

  runApp(const ProviderScope(child: _Bootstrap()));
}

/// Awaits the SharedPreferences future once at startup so the rest of the
/// providers can read it synchronously.
class _Bootstrap extends ConsumerWidget {
  const _Bootstrap();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final prefs = ref.watch(sharedPrefsProvider);
    return prefs.when(
      loading: () => const _BootSplash(),
      error: (e, _) => MaterialApp(
        home: Scaffold(body: Center(child: Text('Failed to start: $e'))),
      ),
      data: (_) => const PulseEdgeApp(),
    );
  }
}

class _BootSplash extends StatelessWidget {
  const _BootSplash();

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: ColoredBox(color: Color(0xFFE7E5E4)),
    );
  }
}
