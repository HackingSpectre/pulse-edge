import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'tokens.dart';

/// App-wide ThemeData. Most of the visual language is custom-rendered by
/// neumorphic widgets (see lib/shared/widgets/), but this theme handles the
/// Material defaults that bleed into transitive widgets (TextField cursor
/// color, Snackbar, Tooltip, default text style).
class AppTheme {
  AppTheme._();

  static ThemeData light() {
    final base = ThemeData.light(useMaterial3: true);
    final colorScheme = ColorScheme.light(
      primary: T.primary,
      onPrimary: T.inkInverse,
      primaryContainer: T.primarySoft,
      onPrimaryContainer: T.primary,
      secondary: T.primary,
      onSecondary: T.inkInverse,
      surface: T.surface,
      onSurface: T.ink,
      error: T.danger,
      onError: T.inkInverse,
    );

    return base.copyWith(
      colorScheme: colorScheme,
      scaffoldBackgroundColor: T.surface,
      canvasColor: T.surface,
      dividerColor: T.divider,
      splashFactory: NoSplash.splashFactory,
      highlightColor: Colors.transparent,
      hoverColor: Colors.transparent,
      textSelectionTheme: const TextSelectionThemeData(
        cursorColor: T.primary,
        selectionColor: Color(0x33006666),
        selectionHandleColor: T.primary,
      ),
      textTheme: _textTheme(),
      iconTheme: const IconThemeData(color: T.ink, size: T.iconMd),
      tooltipTheme: TooltipThemeData(
        preferBelow: false,
        decoration: BoxDecoration(
          color: T.ink,
          borderRadius: T.brSm,
        ),
        textStyle: const TextStyle(
          color: T.inkInverse,
          fontFamily: T.fontBody,
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: T.ink,
        contentTextStyle: const TextStyle(
          color: T.inkInverse,
          fontFamily: T.fontBody,
          fontWeight: FontWeight.w500,
        ),
        behavior: SnackBarBehavior.floating,
        elevation: 0,
        shape: const RoundedRectangleBorder(borderRadius: T.brSm),
      ),
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: <TargetPlatform, PageTransitionsBuilder>{
          TargetPlatform.android: _NeuPageTransitionBuilder(),
          TargetPlatform.iOS: _NeuPageTransitionBuilder(),
        },
      ),
    );
  }

  /// System UI overlay — transparent status bar, dark icons on the light
  /// neumorphic surface for WCAG-compliant contrast.
  static const SystemUiOverlayStyle systemOverlay = SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarBrightness: Brightness.light,
    statusBarIconBrightness: Brightness.dark,
    systemNavigationBarColor: T.surface,
    systemNavigationBarIconBrightness: Brightness.dark,
    systemNavigationBarDividerColor: Colors.transparent,
  );

  static TextTheme _textTheme() => const TextTheme(
        displayLarge: T.display1,
        displayMedium: T.display2,
        headlineLarge: T.h1,
        headlineMedium: T.h2,
        headlineSmall: T.h3,
        titleLarge: T.h2,
        titleMedium: T.h3,
        titleSmall: T.bodyStrong,
        bodyLarge: T.body,
        bodyMedium: T.body,
        bodySmall: T.caption,
        labelLarge: T.bodyStrong,
        labelMedium: T.label,
        labelSmall: T.label,
      );
}

class _NeuPageTransitionBuilder extends PageTransitionsBuilder {
  const _NeuPageTransitionBuilder();

  @override
  Widget buildTransitions<R>(
    PageRoute<R> route,
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    final fade = CurvedAnimation(parent: animation, curve: Curves.easeOutCubic);
    final slide = Tween<Offset>(
      begin: const Offset(0, 0.025),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: animation, curve: Curves.easeOutCubic));
    return FadeTransition(
      opacity: fade,
      child: SlideTransition(position: slide, child: child),
    );
  }
}
