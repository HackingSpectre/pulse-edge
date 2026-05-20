import 'package:flutter/material.dart';

/// Design tokens for the neumorphism design system.
///
/// All component styling must read from this file. Do not hard-code colors,
/// spacing, type sizes, or radii anywhere in the app — the entire visual
/// language is intended to be re-skinnable from here.
///
/// Source: design-system skill at `.agents/skills/design-system/SKILL.md`.
class T {
  T._();

  // ────────────────────────────────────────────────────────────────────────
  // COLOR — primary, secondary, semantic, surface, ink
  // ────────────────────────────────────────────────────────────────────────

  /// Brand teal. Used for primary CTAs, focus rings, key data emphasis.
  static const Color primary = Color(0xFF006666);
  static const Color primaryHover = Color(0xFF005252);
  static const Color primarySoft = Color(0xFFE0EFEF);

  /// Cool secondary surface — used for elevated layered cards.
  static const Color secondary = Color(0xFFF1F2F5);

  /// Semantic colors for severity, status, and feedback.
  static const Color success = Color(0xFF00A63D);
  static const Color successSoft = Color(0xFFE3F8EB);
  static const Color warning = Color(0xFFFE9900);
  static const Color warningSoft = Color(0xFFFFF1DE);
  static const Color danger = Color(0xFFFF2157);
  static const Color dangerSoft = Color(0xFFFFE3EB);
  static const Color info = Color(0xFF1E64FF);
  static const Color infoSoft = Color(0xFFE2ECFF);

  /// Surface — the base "putty" the entire app sits on. Neumorphism requires
  /// every element be the same hue as the surface; only shadows separate them.
  static const Color surface = Color(0xFFE7E5E4);
  static const Color surfaceRaised = Color(0xFFEDECEB);
  static const Color surfaceSunken = Color(0xFFDEDCDB);

  /// Text / ink scale.
  static const Color ink = Color(0xFF1E2938);
  static const Color inkSoft = Color(0xFF52606D);
  static const Color inkMuted = Color(0xFF7B8794);
  static const Color inkDisabled = Color(0xFFB0B7BF);
  static const Color inkInverse = Color(0xFFFFFFFF);

  /// Shadow tokens — the heart of neumorphism. Two opposing shadows on every
  /// surface: a soft highlight (top-left) and a soft drop shadow (bottom-right).
  static const Color shadowDark = Color(0xFFB8B6B5);
  static const Color shadowLight = Color(0xFFFFFFFF);

  /// Hairline divider for separating list rows when shadows aren't enough.
  static const Color divider = Color(0x14000000);

  // ────────────────────────────────────────────────────────────────────────
  // TYPOGRAPHY — Space Mono for everything per the design skill.
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
    letterSpacing: -0.4,
    color: ink,
  );
  static const TextStyle display2 = TextStyle(
    fontFamily: fontDisplay,
    fontWeight: FontWeight.w700,
    fontSize: 28,
    height: 1.15,
    letterSpacing: -0.3,
    color: ink,
  );
  static const TextStyle h1 = TextStyle(
    fontFamily: fontDisplay,
    fontWeight: FontWeight.w700,
    fontSize: 22,
    height: 1.20,
    letterSpacing: -0.2,
    color: ink,
  );
  static const TextStyle h2 = TextStyle(
    fontFamily: fontDisplay,
    fontWeight: FontWeight.w700,
    fontSize: 18,
    height: 1.25,
    letterSpacing: -0.1,
    color: ink,
  );
  static const TextStyle h3 = TextStyle(
    fontFamily: fontDisplay,
    fontWeight: FontWeight.w700,
    fontSize: 16,
    height: 1.30,
    color: ink,
  );
  static const TextStyle body = TextStyle(
    fontFamily: fontBody,
    fontWeight: FontWeight.w400,
    fontSize: 14,
    height: 1.45,
    color: ink,
  );
  static const TextStyle bodyStrong = TextStyle(
    fontFamily: fontBody,
    fontWeight: FontWeight.w700,
    fontSize: 14,
    height: 1.45,
    color: ink,
  );
  static const TextStyle bodySoft = TextStyle(
    fontFamily: fontBody,
    fontWeight: FontWeight.w400,
    fontSize: 14,
    height: 1.45,
    color: inkSoft,
  );
  static const TextStyle caption = TextStyle(
    fontFamily: fontBody,
    fontWeight: FontWeight.w400,
    fontSize: 12,
    height: 1.40,
    letterSpacing: 0.1,
    color: inkMuted,
  );
  static const TextStyle label = TextStyle(
    fontFamily: fontBody,
    fontWeight: FontWeight.w700,
    fontSize: 12,
    height: 1.30,
    letterSpacing: 0.6,
    color: inkSoft,
  );
  static const TextStyle mono = TextStyle(
    fontFamily: fontMono,
    fontWeight: FontWeight.w500,
    fontSize: 13,
    height: 1.30,
    color: ink,
  );

  /// Big metric numerals (HR, temperature). Always tabular for stable layout.
  static const TextStyle metricHero = TextStyle(
    fontFamily: fontDisplay,
    fontWeight: FontWeight.w700,
    fontSize: 56,
    height: 1.0,
    letterSpacing: -1.0,
    color: ink,
    fontFeatures: [FontFeature.tabularFigures()],
  );
  static const TextStyle metricLarge = TextStyle(
    fontFamily: fontDisplay,
    fontWeight: FontWeight.w700,
    fontSize: 32,
    height: 1.0,
    letterSpacing: -0.5,
    color: ink,
    fontFeatures: [FontFeature.tabularFigures()],
  );
  static const TextStyle metricSmall = TextStyle(
    fontFamily: fontDisplay,
    fontWeight: FontWeight.w700,
    fontSize: 20,
    height: 1.0,
    color: ink,
    fontFeatures: [FontFeature.tabularFigures()],
  );

  // ────────────────────────────────────────────────────────────────────────
  // SPACING — compact scale (4px base).
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

  // Page-level horizontal padding. Scales with screen width — set in theme.
  static const double pagePadding = 20;

  // ────────────────────────────────────────────────────────────────────────
  // RADIUS — generous, rounded but not pill-y. Soft enough for neumorphism.
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
  // ELEVATION — neumorphic shadow recipes. Each "level" is a (light, dark)
  // pair of BoxShadows. RAISED = extruded outward. SUNKEN = pressed inward
  // (rendered via a separate inset shadow widget).
  // ────────────────────────────────────────────────────────────────────────

  static const double blurXs = 4;
  static const double blurSm = 8;
  static const double blurMd = 14;
  static const double blurLg = 22;

  static const Offset offsetXs = Offset(2, 2);
  static const Offset offsetSm = Offset(4, 4);
  static const Offset offsetMd = Offset(7, 7);
  static const Offset offsetLg = Offset(11, 11);

  /// Raised shadow stack. Two opposing shadows per the design language.
  static List<BoxShadow> raisedXs() => [
        BoxShadow(color: shadowDark.withValues(alpha: 0.45), offset: offsetXs, blurRadius: blurXs),
        BoxShadow(color: shadowLight.withValues(alpha: 0.95), offset: -offsetXs, blurRadius: blurXs),
      ];
  static List<BoxShadow> raisedSm() => [
        BoxShadow(color: shadowDark.withValues(alpha: 0.50), offset: offsetSm, blurRadius: blurSm),
        BoxShadow(color: shadowLight.withValues(alpha: 0.95), offset: -offsetSm, blurRadius: blurSm),
      ];
  static List<BoxShadow> raisedMd() => [
        BoxShadow(color: shadowDark.withValues(alpha: 0.55), offset: offsetMd, blurRadius: blurMd),
        BoxShadow(color: shadowLight.withValues(alpha: 1.0), offset: -offsetMd, blurRadius: blurMd),
      ];
  static List<BoxShadow> raisedLg() => [
        BoxShadow(color: shadowDark.withValues(alpha: 0.55), offset: offsetLg, blurRadius: blurLg),
        BoxShadow(color: shadowLight.withValues(alpha: 1.0), offset: -offsetLg, blurRadius: blurLg),
      ];

  // ────────────────────────────────────────────────────────────────────────
  // MOTION — durations + curves. "decorative motion without purpose" is
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
  // HIT TARGET — minimum 48dp per WCAG 2.2 AA Target Size.
  // ────────────────────────────────────────────────────────────────────────

  static const double minTap = 48;
}
