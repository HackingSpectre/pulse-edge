import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers.dart';
import '../../../core/theme/tokens.dart';
import '../../../shared/widgets/widgets.dart';

class StepSetPin extends ConsumerStatefulWidget {
  const StepSetPin({super.key});

  @override
  ConsumerState<StepSetPin> createState() => _StepSetPinState();
}

class _StepSetPinState extends ConsumerState<StepSetPin> {
  String _first = '';
  String _confirm = '';
  bool _confirming = false;
  bool _shake = false;
  String? _error;

  static const int _pinLen = 6;

  Future<void> _onDigit(int d) async {
    if (!_confirming) {
      if (_first.length < _pinLen) {
        setState(() {
          _first += '$d';
          _error = null;
        });
        if (_first.length == _pinLen) {
          // Move to confirm.
          await Future<void>.delayed(const Duration(milliseconds: 180));
          if (!mounted) return;
          setState(() => _confirming = true);
        }
      }
    } else {
      if (_confirm.length < _pinLen) {
        setState(() {
          _confirm += '$d';
          _error = null;
        });
        if (_confirm.length == _pinLen) {
          await Future<void>.delayed(const Duration(milliseconds: 180));
          await _maybeSubmit();
        }
      }
    }
  }

  Future<void> _maybeSubmit() async {
    if (_first == _confirm) {
      await ref.read(authServiceProvider).setPin(_first);
      ref.read(isLockedProvider.notifier).unlock();
    } else {
      setState(() {
        _error = 'PINs don\'t match. Try again.';
        _shake = true;
        _confirm = '';
      });
      await Future<void>.delayed(const Duration(milliseconds: 380));
      if (!mounted) return;
      setState(() => _shake = false);
    }
  }

  void _backspace() {
    setState(() {
      _error = null;
      if (!_confirming) {
        if (_first.isNotEmpty) _first = _first.substring(0, _first.length - 1);
      } else {
        if (_confirm.isNotEmpty) {
          _confirm = _confirm.substring(0, _confirm.length - 1);
        } else {
          _confirming = false;
          _first = '';
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final entered = _confirming ? _confirm.length : _first.length;
    return Column(
      children: [
        const SizedBox(height: T.space4),
        Text(
          _confirming ? 'Confirm your PIN' : 'Set a 6-digit PIN',
          style: T.h1,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: T.space2),
        Text(
          _confirming
              ? 'Type it again so we know it stuck.'
              : 'Used to unlock the app. Picked something memorable.',
          style: T.bodySoft,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: T.space7),
        NeuPinDots(length: _pinLen, entered: entered, shake: _shake),
        if (_error != null) ...[
          const SizedBox(height: T.space4),
          Text(_error!, style: T.caption.copyWith(color: T.danger)),
        ],
        const SizedBox(height: T.space6),
        NeuPinKeypad(onDigit: _onDigit, onBackspace: _backspace),
      ],
    );
  }
}
