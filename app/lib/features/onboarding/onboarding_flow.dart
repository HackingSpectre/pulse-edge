import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/router.dart';
import '../../core/providers.dart';
import '../../core/theme/tokens.dart';
import '../../shared/widgets/widgets.dart';
import 'steps/step_calibration.dart';
import 'steps/step_intro.dart';
import 'steps/step_pair_device.dart';
import 'steps/step_permissions.dart';
import 'steps/step_profile.dart';
import 'steps/step_set_pin.dart';
import 'steps/step_value_props.dart';
import 'steps/step_done.dart';

/// 8-step onboarding wizard with neumorphic step indicator + slide
/// transitions. Each step is self-contained and exposes its own
/// "can advance" guard via the [OnboardingStep.canAdvance] callback.
class OnboardingFlow extends ConsumerStatefulWidget {
  const OnboardingFlow({super.key});

  @override
  ConsumerState<OnboardingFlow> createState() => _OnboardingFlowState();
}

class _OnboardingFlowState extends ConsumerState<OnboardingFlow> {
  final _pageCtrl = PageController();
  final _profileKey = GlobalKey<StepProfileState>();
  int _index = 0;

  late final List<OnboardingStep> _steps = [
    OnboardingStep(builder: (_) => const StepIntro()),
    OnboardingStep(builder: (_) => const StepValueProps()),
    OnboardingStep(builder: (_) => const StepPermissions()),
    OnboardingStep(builder: (_) => const StepSetPin()),
    OnboardingStep(builder: (_) => StepProfile(key: _profileKey)),
    OnboardingStep(builder: (_) => const StepPairDevice()),
    OnboardingStep(builder: (_) => const StepCalibration()),
    OnboardingStep(builder: (_) => const StepDone()),
  ];

  @override
  void dispose() {
    _pageCtrl.dispose();
    super.dispose();
  }

  Future<void> _next() async {
    if (!await _canLeaveCurrentStep()) return;
    if (_index < _steps.length - 1) {
      _pageCtrl.nextPage(duration: T.motionPage, curve: T.emphasized);
    } else {
      _finish();
    }
  }

  Future<bool> _canLeaveCurrentStep() async {
    if (_index == 3) {
      final hasPin = await ref.read(authServiceProvider).hasPin();
      if (!hasPin) {
        _showMessage('Set and confirm your PIN before continuing.');
        return false;
      }
    }
    if (_index == 4) {
      await _profileKey.currentState?.save();
    }
    return true;
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  void _back() {
    if (_index == 0) return;
    _pageCtrl.previousPage(duration: T.motionPage, curve: T.emphasized);
  }

  Future<void> _finish() async {
    await ref.read(settingsProvider).setOnboardingComplete(true);
    ref.invalidate(routerProvider);
    ref.read(isLockedProvider.notifier).unlock();
    if (!mounted) return;
    context.go(Routes.dashboard);
  }

  @override
  Widget build(BuildContext context) {
    final isLast = _index == _steps.length - 1;
    return PopScope(
      canPop: _index == 0,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _back();
      },
      child: Scaffold(
        backgroundColor: T.surface,
        body: NeuChassisBackground(
          child: SafeArea(
            child: Column(
              children: [
                _Header(
                  index: _index,
                  total: _steps.length,
                  onBack: _index == 0 ? null : _back,
                ),
                Expanded(
                  child: PageView.builder(
                    controller: _pageCtrl,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _steps.length,
                    onPageChanged: (i) => setState(() => _index = i),
                    itemBuilder: (context, i) => Padding(
                      padding: const EdgeInsets.fromLTRB(
                        T.pagePadding,
                        T.space2,
                        T.pagePadding,
                        0,
                      ),
                      child: _steps[i].builder(context),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(
                    T.pagePadding,
                    T.space4,
                    T.pagePadding,
                    T.space5,
                  ),
                  child: NeuButton(
                    label: isLast ? 'Start' : 'Continue',
                    variant: NeuButtonVariant.filled,
                    expanded: true,
                    size: NeuSize.lg,
                    onPressed: _next,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class OnboardingStep {
  OnboardingStep({required this.builder});
  final WidgetBuilder builder;
}

class _Header extends StatelessWidget {
  const _Header({required this.index, required this.total, this.onBack});
  final int index;
  final int total;
  final VoidCallback? onBack;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        T.space4,
        T.space4,
        T.space4,
        T.space2,
      ),
      child: Row(
        children: [
          NeuIconButton(
            icon: Icons.arrow_back_rounded,
            onPressed: onBack,
            tooltip: 'Back',
          ),
          const SizedBox(width: T.space4),
          Expanded(child: NeuLinearProgress(value: (index + 1) / total)),
          const SizedBox(width: T.space4),
          Text(
            '${index + 1}/$total',
            style: T.label.copyWith(color: T.inkSoft),
          ),
        ],
      ),
    );
  }
}
