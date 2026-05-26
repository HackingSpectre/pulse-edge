import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/theme/app_theme.dart';
import '../../core/theme/tokens.dart';
import 'chassis_painter.dart';
import 'neu_button.dart';

/// Page-level wrapper. Sets the system UI overlay, provides safe-area
/// padding, and renders an optional neumorphic app bar.
class NeuScaffold extends StatelessWidget {
  const NeuScaffold({
    super.key,
    this.title,
    this.leading,
    this.actions,
    this.body,
    this.bottom,
    this.bottomNavigationBar,
    this.padding = const EdgeInsets.fromLTRB(
      T.pagePadding,
      T.space5,
      T.pagePadding,
      T.space5,
    ),
    this.scrollable = false,
    this.resizeToAvoidBottomInset = true,
    this.onBack,
    this.showBack = false,
    this.backgroundColor,
    this.floatingActionButton,
  });

  final String? title;
  final Widget? leading;
  final List<Widget>? actions;
  final Widget? body;
  final Widget? bottom;
  final Widget? bottomNavigationBar;
  final EdgeInsetsGeometry padding;
  final bool scrollable;
  final bool resizeToAvoidBottomInset;
  final bool showBack;
  final VoidCallback? onBack;
  final Color? backgroundColor;
  final Widget? floatingActionButton;

  @override
  Widget build(BuildContext context) {
    Widget content = Padding(
      padding: padding,
      child: body ?? const SizedBox.shrink(),
    );
    if (scrollable) {
      content = SingleChildScrollView(
        padding: padding,
        physics: const BouncingScrollPhysics(),
        child: body ?? const SizedBox.shrink(),
      );
    }

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: AppTheme.systemOverlay,
      child: Scaffold(
        backgroundColor: backgroundColor ?? T.surface,
        resizeToAvoidBottomInset: resizeToAvoidBottomInset,
        floatingActionButton: floatingActionButton,
        body: NeuChassisBackground(
          child: SafeArea(
            bottom: false,
            child: Column(
              children: [
                if (title != null ||
                    showBack ||
                    actions != null ||
                    leading != null)
                  _NeuAppBar(
                    title: title,
                    leading: leading,
                    actions: actions,
                    showBack: showBack,
                    onBack: onBack ?? () => Navigator.of(context).maybePop(),
                  ),
                Expanded(child: content),
                ?bottom,
              ],
            ),
          ),
        ),
        bottomNavigationBar: bottomNavigationBar,
      ),
    );
  }
}

class NeuChassisBackground extends StatelessWidget {
  const NeuChassisBackground({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final chassisColor = Theme.of(context).brightness == Brightness.dark
        ? Colors.white.withValues(alpha: 0.055)
        : Colors.black.withValues(alpha: 0.055);
    return Stack(
      children: [
        Positioned.fill(
          child: CustomPaint(painter: ChassisPainter(color: chassisColor)),
        ),
        child,
      ],
    );
  }
}

class _NeuAppBar extends StatelessWidget {
  const _NeuAppBar({
    this.title,
    this.leading,
    this.actions,
    this.showBack = false,
    required this.onBack,
  });

  final String? title;
  final Widget? leading;
  final List<Widget>? actions;
  final bool showBack;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        T.space4,
        T.space3,
        T.space4,
        T.space2,
      ),
      child: Row(
        children: [
          if (showBack)
            NeuIconButton(
              icon: Icons.arrow_back_rounded,
              onPressed: onBack,
              tooltip: 'Back',
            )
          else
            ?leading,
          if ((showBack || leading != null) && title != null)
            const SizedBox(width: T.space3),
          if (title case final t?)
            Expanded(
              child: Text(
                t,
                style: T.h1,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            )
          else
            const Spacer(),
          ...?actions
              ?.expand((w) => [const SizedBox(width: T.space2), w])
              .skip(1),
        ],
      ),
    );
  }
}
