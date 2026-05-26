import 'package:flutter/material.dart';

/// Design tokens for the neumorphism design system.
///
/// All component styling must read from this file. Do not hard-code colors,
/// spacing, type sizes, or radii anywhere in the app - the entire visual
/// language is intended to be re-skinnable from here.
///
/// Source: design-system skill at `.agents/skills/design-system/SKILL.md`.
class T {
  T._();

  // ────────────────────────────────────────────────────────────────────────
  // COLOR - primary, secondary, semantic, surface, ink
  // ────────────────────────────────────────────────────────────────────────

  static Brightness? _brightnessOverride;

  static R resolveFor<R>(Brightness brightness, R Function() resolve) {
    final previous = _brightnessOverride;
    _brightnessOverride = brightness;
    try {
      return resolve();
    } finally {
      _brightnessOverride = previous;
    }
  }

  static bool get isDark =>
      (_brightnessOverride ??
          WidgetsBinding.instance.platformDispatcher.platformBrightness) ==
      Brightness.dark;

  /// Monochrome action tone. Light mode resolves to matte black; dark mode
  /// resolves to off-white.
  static Color get primary =>
      isDark ? const Color(0xFFF2F1EC) : const Color(0xFF111111);
  static Color get primaryHover =>
      isDark ? const Color(0xFFFFFFFF) : const Color(0xFF000000);
  static Color get primarySoft =>
      isDark ? const Color(0xFF252525) : const Color(0xFFE3E1DC);

  /// Secondary surface - same monochrome family, never chromatic.
  static Color get secondary =>
      isDark ? const Color(0xFF18191A) : const Color(0xFFF3F2EF);

  /// Semantic tones are deliberately grayscale to preserve the strict
  /// monochrome interface while still allowing hierarchy.
  static Color get success =>
      isDark ? const Color(0xFFE5E2DA) : const Color(0xFF303030);
  static Color get successSoft =>
      isDark ? const Color(0xFF232323) : const Color(0xFFE8E6E1);
  static Color get warning =>
      isDark ? const Color(0xFFC7C3BA) : const Color(0xFF555555);
  static Color get warningSoft =>
      isDark ? const Color(0xFF1F2020) : const Color(0xFFE1DFDA);
  static Color get danger =>
      isDark ? const Color(0xFFFFFFFF) : const Color(0xFF050505);
  static Color get dangerSoft =>
      isDark ? const Color(0xFF2A2A2A) : const Color(0xFFDAD8D2);
  static Color get info =>
      isDark ? const Color(0xFFD6D3CB) : const Color(0xFF424242);
  static Color get infoSoft =>
      isDark ? const Color(0xFF202122) : const Color(0xFFE5E3DE);

  /// Surface - the base chassis the entire app sits on.
  static Color get surface =>
      isDark ? const Color(0xFF101111) : const Color(0xFFF1F0EC);
  static Color get surfaceRaised =>
      isDark ? const Color(0xFF18191A) : const Color(0xFFF8F7F4);
  static Color get surfaceSunken =>
      isDark ? const Color(0xFF080909) : const Color(0xFFE2E0DB);

  /// Text / ink scale.
  static Color get ink =>
      isDark ? const Color(0xFFF4F2ED) : const Color(0xFF111111);
  static Color get inkSoft =>
      isDark ? const Color(0xFFC7C3BB) : const Color(0xFF424242);
  static Color get inkMuted =>
      isDark ? const Color(0xFF8C8982) : const Color(0xFF6B6964);
  static Color get inkDisabled =>
      isDark ? const Color(0xFF5F5D58) : const Color(0xFFAAA69E);
  static Color get inkInverse =>
      isDark ? const Color(0xFF0A0A0A) : const Color(0xFFFFFFFF);

  /// Shadow tokens - firmer than classic pillow neumorphism.
  static Color get shadowDark =>
      isDark ? const Color(0xFF000000) : const Color(0xFFB9B6AE);
  static Color get shadowLight =>
      isDark ? const Color(0xFF2C2D2E) : const Color(0xFFFFFFFF);

  /// Hairline divider for separating list rows when shadows aren't enough.
  static Color get divider =>
      isDark ? const Color(0x24FFFFFF) : const Color(0x18000000);

  // ────────────────────────────────────────────────────────────────────────
  // TYPOGRAPHY - Space Mono for everything per the design skill.
  // ────────────────────────────────────────────────────────────────────────

  static const String fontDisplay = 'SpaceMono';
  static const String fontBody = 'SpaceMono';
  static const String fontMono = 'JetBrainsMono';

  // Modular type scale, slightly compressed for compact density.
  static const TextStyle display1 = TextStyle(
    fontFamily: fontDisplay,
    fontWeight: FontWeight.w700,
    fontSize: 36,
    height: 1.10,
    letterSpacing: 0,
  );
  static const TextStyle display2 = TextStyle(
    fontFamily: fontDisplay,
    fontWeight: FontWeight.w700,
    fontSize: 28,
    height: 1.15,
    letterSpacing: 0,
  );
  static const TextStyle h1 = TextStyle(
    fontFamily: fontDisplay,
    fontWeight: FontWeight.w700,
    fontSize: 22,
    height: 1.20,
    letterSpacing: 0,
  );
  static const TextStyle h2 = TextStyle(
    fontFamily: fontDisplay,
    fontWeight: FontWeight.w700,
    fontSize: 18,
    height: 1.25,
    letterSpacing: 0,
  );
  static const TextStyle h3 = TextStyle(
    fontFamily: fontDisplay,
    fontWeight: FontWeight.w700,
    fontSize: 16,
    height: 1.30,
  );
  static const TextStyle body = TextStyle(
    fontFamily: fontBody,
    fontWeight: FontWeight.w400,
    fontSize: 14,
    height: 1.45,
  );
  static const TextStyle bodyStrong = TextStyle(
    fontFamily: fontBody,
    fontWeight: FontWeight.w700,
    fontSize: 14,
    height: 1.45,
  );
  static const TextStyle bodySoft = TextStyle(
    fontFamily: fontBody,
    fontWeight: FontWeight.w400,
    fontSize: 14,
    height: 1.45,
  );
  static const TextStyle caption = TextStyle(
    fontFamily: fontBody,
    fontWeight: FontWeight.w400,
    fontSize: 12,
    height: 1.40,
    letterSpacing: 0,
  );
  static const TextStyle label = TextStyle(
    fontFamily: fontBody,
    fontWeight: FontWeight.w700,
    fontSize: 12,
    height: 1.30,
    letterSpacing: 0,
  );
  static const TextStyle mono = TextStyle(
    fontFamily: fontMono,
    fontWeight: FontWeight.w500,
    fontSize: 13,
    height: 1.30,
  );

  /// Big metric numerals (HR, temperature). Always tabular for stable layout.
  static const TextStyle metricHero = TextStyle(
    fontFamily: fontDisplay,
    fontWeight: FontWeight.w700,
    fontSize: 56,
    height: 1.0,
    letterSpacing: 0,
    fontFeatures: [FontFeature.tabularFigures()],
  );
  static const TextStyle metricLarge = TextStyle(
    fontFamily: fontDisplay,
    fontWeight: FontWeight.w700,
    fontSize: 32,
    height: 1.0,
    letterSpacing: 0,
    fontFeatures: [FontFeature.tabularFigures()],
  );
  static const TextStyle metricSmall = TextStyle(
    fontFamily: fontDisplay,
    fontWeight: FontWeight.w700,
    fontSize: 20,
    height: 1.0,
    fontFeatures: [FontFeature.tabularFigures()],
  );

  // ────────────────────────────────────────────────────────────────────────
  // SPACING - compact scale (4px base).
  // ────────────────────────────────────────────────────────────────────────

  static const double space1 = 4;
  static const double space2 = 8;
  static const double space3 = 12;
  static const double space4 = 16;
  static const double space5 = 20;
  static const double space6 = 24;
  static const double space7 = 32;
  static const double space8 = 40;
  static const double space9 = 48;
  static const double space10 = 64;

  // Page-level horizontal padding. Scales with screen width - set in theme.
  static const double pagePadding = 20;

  // ────────────────────────────────────────────────────────────────────────
  // RADIUS - generous, rounded but not pill-y. Soft enough for neumorphism.
  // ────────────────────────────────────────────────────────────────────────

  static const Radius rXs = Radius.circular(6);
  static const Radius rSm = Radius.circular(10);
  static const Radius rMd = Radius.circular(16);
  static const Radius rLg = Radius.circular(22);
  static const Radius rXl = Radius.circular(28);
  static const Radius rPill = Radius.circular(999);

  static const BorderRadius brXs = BorderRadius.all(rXs);
  static const BorderRadius brSm = BorderRadius.all(rSm);
  static const BorderRadius brMd = BorderRadius.all(rMd);
  static const BorderRadius brLg = BorderRadius.all(rLg);
  static const BorderRadius brXl = BorderRadius.all(rXl);
  static const BorderRadius brPill = BorderRadius.all(rPill);

  // ────────────────────────────────────────────────────────────────────────
  // ELEVATION - neumorphic shadow recipes. Each "level" is a (light, dark)
  // pair of BoxShadows. RAISED = extruded outward. SUNKEN = pressed inward
  // (rendered via a separate inset shadow widget).
  // ────────────────────────────────────────────────────────────────────────

  static const double blurXs = 4;
  static const double blurSm = 8;
  static const double blurMd = 10;
  static const double blurLg = 16;

  static const Offset offsetXs = Offset(2, 2);
  static const Offset offsetSm = Offset(4, 4);
  static const Offset offsetMd = Offset(7, 7);
  static const Offset offsetLg = Offset(11, 11);

  /// Raised shadow stack. Two opposing shadows per the design language.
  static List<BoxShadow> raisedXs() => [
    BoxShadow(
      color: shadowDark.withValues(alpha: 0.55),
      offset: offsetXs,
      blurRadius: blurXs,
    ),
    BoxShadow(
      color: shadowLight.withValues(alpha: 0.75),
      offset: -offsetXs,
      blurRadius: blurXs,
    ),
  ];
  static List<BoxShadow> raisedSm() => [
    BoxShadow(
      color: shadowDark.withValues(alpha: 0.62),
      offset: offsetSm,
      blurRadius: blurSm,
    ),
    BoxShadow(
      color: shadowLight.withValues(alpha: 0.78),
      offset: -offsetSm,
      blurRadius: blurSm,
    ),
  ];
  static List<BoxShadow> raisedMd() => [
    BoxShadow(
      color: shadowDark.withValues(alpha: 0.68),
      offset: offsetMd,
      blurRadius: blurMd,
    ),
    BoxShadow(
      color: shadowLight.withValues(alpha: 0.82),
      offset: -offsetMd,
      blurRadius: blurMd,
    ),
  ];
  static List<BoxShadow> raisedLg() => [
    BoxShadow(
      color: shadowDark.withValues(alpha: 0.70),
      offset: offsetLg,
      blurRadius: blurLg,
    ),
    BoxShadow(
      color: shadowLight.withValues(alpha: 0.84),
      offset: -offsetLg,
      blurRadius: blurLg,
    ),
  ];

  // ────────────────────────────────────────────────────────────────────────
  // MOTION - durations + curves. "decorative motion without purpose" is
  // explicitly forbidden by the skill, so keep these short and expressive.
  // ────────────────────────────────────────────────────────────────────────

  static const Duration motionFast = Duration(milliseconds: 120);
  static const Duration motionBase = Duration(milliseconds: 220);
  static const Duration motionSlow = Duration(milliseconds: 360);
  static const Duration motionPage = Duration(milliseconds: 320);

  static const Curve easeOut = Curves.easeOutCubic;
  static const Curve easeIn = Curves.easeInCubic;
  static const Curve easeInOut = Curves.easeInOutCubic;
  static const Curve emphasized = Cubic(0.20, 0.00, 0.00, 1.00);

  // ────────────────────────────────────────────────────────────────────────
  // ICON SIZES
  // ────────────────────────────────────────────────────────────────────────

  static const double iconXs = 14;
  static const double iconSm = 18;
  static const double iconMd = 22;
  static const double iconLg = 28;
  static const double iconXl = 40;

  // ────────────────────────────────────────────────────────────────────────
  // HIT TARGET - minimum 48dp per WCAG 2.2 AA Target Size.
  // ────────────────────────────────────────────────────────────────────────

  static const double minTap = 48;
}
