import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/router.dart';
import '../../core/auth/auth_service.dart';
import '../../core/providers.dart';
import '../../core/theme/tokens.dart';
import '../../shared/widgets/widgets.dart';

class SecurityScreen extends ConsumerStatefulWidget {
  const SecurityScreen({super.key});

  @override
  ConsumerState<SecurityScreen> createState() => _SecurityScreenState();
}

class _SecurityScreenState extends ConsumerState<SecurityScreen> {
  final _current = TextEditingController();
  final _next = TextEditingController();
  final _confirm = TextEditingController();
  bool _hasPin = true;
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final hasPin = await ref.read(authServiceProvider).hasPin();
      if (mounted) setState(() => _hasPin = hasPin);
    });
  }

  @override
  void dispose() {
    _current.dispose();
    _next.dispose();
    _confirm.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_busy) return;
    final next = _next.text.trim();
    final confirm = _confirm.text.trim();
    if (!RegExp(r'^\d{6}$').hasMatch(next)) {
      _message('Use a 6-digit PIN.');
      return;
    }
    if (next != confirm) {
      _message('The new PINs do not match.');
      return;
    }
    setState(() => _busy = true);
    final auth = ref.read(authServiceProvider);
    if (_hasPin) {
      final result = await auth.verifyPin(_current.text.trim());
      if (!mounted) return;
      if (result != PinResult.ok) {
        setState(() => _busy = false);
        _message(
          result == PinResult.lockedOut
              ? 'Too many attempts. Try again shortly.'
              : 'Current PIN is incorrect.',
        );
        return;
      }
    }
    await auth.setPin(next);
    if (!mounted) return;
    setState(() => _busy = false);
    _message('PIN updated.');
    context.go(Routes.settings);
  }

  void _message(String text) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));
  }

  @override
  Widget build(BuildContext context) {
    return NeuScaffold(
      title: 'Password',
      showBack: true,
      onBack: () => context.go(Routes.settings),
      scrollable: true,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          NeuCard(
            child: Text(
              'Use a 6-digit PIN to unlock Pulse Edge on this device.',
              style: T.body,
            ),
          ),
          const SizedBox(height: T.space5),
          if (_hasPin) ...[
            NeuTextField(
              controller: _current,
              label: 'Current PIN',
              icon: Icons.lock_outline_rounded,
              obscureText: true,
              keyboardType: TextInputType.number,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(6),
              ],
            ),
            const SizedBox(height: T.space5),
          ],
          NeuTextField(
            controller: _next,
            label: 'New PIN',
            icon: Icons.lock_rounded,
            obscureText: true,
            keyboardType: TextInputType.number,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
              LengthLimitingTextInputFormatter(6),
            ],
          ),
          const SizedBox(height: T.space5),
          NeuTextField(
            controller: _confirm,
            label: 'Confirm new PIN',
            icon: Icons.verified_user_rounded,
            obscureText: true,
            keyboardType: TextInputType.number,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
              LengthLimitingTextInputFormatter(6),
            ],
            textInputAction: TextInputAction.done,
            onSubmitted: (_) => _save(),
          ),
          const SizedBox(height: T.space7),
          NeuButton(
            label: 'Update PIN',
            icon: Icons.save_rounded,
            variant: NeuButtonVariant.filled,
            expanded: true,
            loading: _busy,
            onPressed: _busy ? null : _save,
          ),
        ],
      ),
    );
  }
}
