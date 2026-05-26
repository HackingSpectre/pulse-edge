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
    return _build(Brightness.light);
  }

  static ThemeData dark() {
    return _build(Brightness.dark);
  }

  static ThemeData _build(Brightness brightness) {
    return T.resolveFor(brightness, () {
      final base = ThemeData(useMaterial3: true, brightness: brightness);
      final colorScheme =
          ColorScheme.fromSeed(
            seedColor: brightness == Brightness.dark
                ? const Color(0xFFEDEAE3)
                : const Color(0xFF111111),
            brightness: brightness,
          ).copyWith(
            primary: T.primary,
            onPrimary: T.inkInverse,
            primaryContainer: T.primarySoft,
            onPrimaryContainer: T.primary,
            secondary: T.inkSoft,
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
        textSelectionTheme: TextSelectionThemeData(
          cursorColor: T.primary,
          selectionColor: T.primary.withValues(alpha: 0.18),
          selectionHandleColor: T.primary,
        ),
        textTheme: _textTheme(T.ink),
        iconTheme: IconThemeData(color: T.ink, size: T.iconMd),
        tooltipTheme: TooltipThemeData(
          preferBelow: false,
          decoration: BoxDecoration(color: T.ink, borderRadius: T.brSm),
          textStyle: TextStyle(
            color: T.inkInverse,
            fontFamily: T.fontBody,
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        ),
        snackBarTheme: SnackBarThemeData(
          backgroundColor: T.ink,
          contentTextStyle: TextStyle(
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
    });
  }

  /// System UI overlay - transparent status bar with icons matched to the
  /// active monochrome chassis.
  static SystemUiOverlayStyle get systemOverlay {
    final dark = T.isDark;
    return SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarBrightness: dark ? Brightness.dark : Brightness.light,
      statusBarIconBrightness: dark ? Brightness.light : Brightness.dark,
      systemNavigationBarColor: T.surface,
      systemNavigationBarIconBrightness: dark
          ? Brightness.light
          : Brightness.dark,
      systemNavigationBarDividerColor: Colors.transparent,
    );
  }

  static TextTheme _textTheme(Color ink) => TextTheme(
    displayLarge: T.display1.copyWith(color: ink),
    displayMedium: T.display2.copyWith(color: ink),
    headlineLarge: T.h1.copyWith(color: ink),
    headlineMedium: T.h2.copyWith(color: ink),
    headlineSmall: T.h3.copyWith(color: ink),
    titleLarge: T.h2.copyWith(color: ink),
    titleMedium: T.h3.copyWith(color: ink),
    titleSmall: T.bodyStrong.copyWith(color: ink),
    bodyLarge: T.body.copyWith(color: ink),
    bodyMedium: T.body.copyWith(color: ink),
    bodySmall: T.caption.copyWith(color: T.inkMuted),
    labelLarge: T.bodyStrong.copyWith(color: ink),
    labelMedium: T.label.copyWith(color: T.inkSoft),
    labelSmall: T.label.copyWith(color: T.inkSoft),
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
