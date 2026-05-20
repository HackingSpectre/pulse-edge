import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/router.dart';
import '../../core/auth/auth_service.dart';
import '../../core/providers.dart';
import '../../core/theme/tokens.dart';
import '../../shared/widgets/widgets.dart';

class LockScreen extends ConsumerStatefulWidget {
  const LockScreen({super.key});

  @override
  ConsumerState<LockScreen> createState() => _LockScreenState();
}

class _LockScreenState extends ConsumerState<LockScreen> {
  String _entered = '';
  bool _shake = false;
  bool _busy = false;
  String? _error;
  bool _biometricSupported = false;
  int? _lockoutSecRemaining;
  Timer? _lockoutTimer;

  static const int _len = 6;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final auth = ref.read(authServiceProvider);
      _biometricSupported = await auth.biometricsAvailable();
      final lockMs = await auth.remainingLockoutMs();
      if (mounted) {
        setState(() {
          if (lockMs != null) _lockoutSecRemaining = (lockMs / 1000).ceil();
        });
        if (_lockoutSecRemaining != null) {
          _startLockoutTick();
        } else {
          _tryBiometric();
        }
      }
    });
  }

  void _startLockoutTick() {
    _lockoutTimer?.cancel();
    _lockoutTimer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) return;
      setState(() {
        _lockoutSecRemaining = (_lockoutSecRemaining ?? 1) - 1;
        if (_lockoutSecRemaining! <= 0) {
          _lockoutSecRemaining = null;
          _lockoutTimer?.cancel();
          _error = null;
        }
      });
    });
  }

  Future<void> _tryBiometric() async {
    if (!_biometricSupported) return;
    final res =
        await ref.read(authServiceProvider).authenticateBiometric();
    if (res == BiometricResult.ok && mounted) {
      _unlock();
    }
  }

  Future<void> _onDigit(int d) async {
    if (_lockoutSecRemaining != null) return;
    if (_entered.length >= _len) return;
    setState(() {
      _entered += '$d';
      _error = null;
    });
    if (_entered.length == _len) {
      await _verify();
    }
  }

  void _backspace() {
    setState(() {
      _entered = _entered.isEmpty ? '' : _entered.substring(0, _entered.length - 1);
      _error = null;
    });
  }

  Future<void> _verify() async {
    setState(() => _busy = true);
    final res = await ref.read(authServiceProvider).verifyPin(_entered);
    if (!mounted) return;
    setState(() => _busy = false);
    switch (res) {
      case PinResult.ok:
        HapticFeedback.lightImpact();
        _unlock();
      case PinResult.wrong:
        HapticFeedback.heavyImpact();
        setState(() {
          _error = 'Wrong PIN';
          _shake = true;
          _entered = '';
        });
        await Future<void>.delayed(const Duration(milliseconds: 380));
        if (mounted) setState(() => _shake = false);
      case PinResult.lockedOut:
        final ms = await ref.read(authServiceProvider).remainingLockoutMs();
        if (mounted) {
          setState(() {
            _lockoutSecRemaining = ((ms ?? 30000) / 1000).ceil();
            _entered = '';
            _error = 'Too many attempts';
          });
          _startLockoutTick();
        }
      case PinResult.notSet:
        if (mounted) context.go(Routes.onboarding);
    }
  }

  void _unlock() {
    ref.read(isLockedProvider.notifier).unlock();
    context.go(Routes.dashboard);
  }

  @override
  void dispose() {
    _lockoutTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: T.surface,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(T.pagePadding),
          child: Column(
            children: [
              const Spacer(),
              NeuSurface(
                depth: NeuDepth.raised,
                size: NeuSize.lg,
                borderRadius: BorderRadius.circular(48),
                padding: const EdgeInsets.all(T.space5),
                child: const Icon(Icons.lock_rounded,
                    size: 36, color: T.primary),
              ),
              const SizedBox(height: T.space5),
              Text('Welcome back', style: T.h1),
              const SizedBox(height: T.space2),
              Text('Enter your PIN to unlock', style: T.bodySoft),
              const SizedBox(height: T.space7),
              NeuPinDots(length: _len, entered: _entered.length, shake: _shake),
              const SizedBox(height: T.space5),
              if (_error != null)
                Text(_error!, style: T.caption.copyWith(color: T.danger)),
              if (_lockoutSecRemaining != null)
                Padding(
                  padding: const EdgeInsets.only(top: T.space2),
                  child: Text(
                    'Try again in ${_lockoutSecRemaining}s',
                    style: T.caption.copyWith(color: T.danger),
                  ),
                ),
              const SizedBox(height: T.space5),
              if (_busy)
                const SizedBox(
                  height: 18,
                  width: 18,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: T.primary,
                  ),
                ),
              const Spacer(),
              NeuPinKeypad(
                onDigit: _onDigit,
                onBackspace: _backspace,
                onBiometric: _biometricSupported ? _tryBiometric : null,
              ),
              const SizedBox(height: T.space3),
            ],
          ),
        ),
      ),
    );
  }
}
