import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/router.dart';
import '../../core/providers.dart';
import '../../core/theme/tokens.dart';
import '../../shared/widgets/widgets.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 900),
  )..forward();
  late final Animation<double> _scale = CurvedAnimation(
    parent: _c,
    curve: Curves.easeOutBack,
  );
  late final Animation<double> _fade = CurvedAnimation(
    parent: _c,
    curve: const Interval(0.4, 1.0, curve: Curves.easeOut),
  );

  @override
  void initState() {
    super.initState();
    Timer(const Duration(milliseconds: 1100), _go);
  }

  Future<void> _go() async {
    if (!mounted) return;
    final settings = ref.read(settingsProvider);
    final auth = ref.read(authServiceProvider);
    if (!settings.onboardingComplete) {
      if (mounted) context.go(Routes.onboarding);
      return;
    }
    final hasPin = await auth.hasPin();
    if (!mounted) return;
    if (!hasPin) {
      context.go(Routes.onboarding);
    } else {
      context.go(Routes.lock);
    }
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: T.surface,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ScaleTransition(
              scale: _scale,
              child: const _Logo(),
            ),
            const SizedBox(height: T.space7),
            FadeTransition(
              opacity: _fade,
              child: Text('PULSE EDGE',
                  style: T.label.copyWith(letterSpacing: 4, color: T.inkSoft)),
            ),
          ],
        ),
      ),
    );
  }
}

class _Logo extends StatefulWidget {
  const _Logo();

  @override
  State<_Logo> createState() => _LogoState();
}

class _LogoState extends State<_Logo> with SingleTickerProviderStateMixin {
  late final AnimationController _pulse = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1400),
  )..repeat();

  @override
  void dispose() {
    _pulse.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _pulse,
      builder: (context, _) {
        final t = (_pulse.value < 0.5
                ? _pulse.value * 2
                : (1 - _pulse.value) * 2)
            .clamp(0.0, 1.0);
        return SizedBox(
          width: 160,
          height: 160,
          child: Stack(
            alignment: Alignment.center,
            children: [
              NeuSurface(
                depth: NeuDepth.raised,
                size: NeuSize.lg,
                borderRadius: BorderRadius.circular(80),
                width: 160,
                height: 160,
              ),
              Transform.scale(
                scale: 1.0 + t * 0.08,
                child: Icon(
                  Icons.favorite_rounded,
                  size: 64,
                  color: Color.lerp(T.primary, T.danger, t * 0.6),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
