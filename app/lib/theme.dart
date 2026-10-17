import 'package:flutter/material.dart';

/// Design tokens for Link — Adwaita-inspired, warm autumn palette.
class LinkColors {
  static const background = Color(0xFFF0E9DD);
  static const card = Color(0xFFFBF7F1);
  static const border = Color(0xFFE0D6C6);
  static const accent = Color(0xFFDD5B35);
  static const accentSoft = Color(0xFFF7DDD1);
  static const accentDark = Color(0xFF3A322C);
  static const text = Color(0xFF2A2420);
  static const muted = Color(0xFF8A8074);
  static const faint = Color(0xFFB5AA99);
  static const ok = Color(0xFF4C8C4E);
  static const okSoft = Color(0xFFE3EFE0);
  static const err = Color(0xFFC0392B);
  static const errSoft = Color(0xFFF6E1DD);
  static const warn = Color(0xFFDD9A35);
  static const warnSoft = Color(0xFFF7EBD6);
  static const dark = Color(0xFF1A1A1A);
  static const white = Color(0xFFFFFFFF);
}

class LinkRadii {
  static const sm = 10.0;
  static const md = 14.0;
  static const lg = 18.0;
  static const xl = 24.0;
  static const pill = 999.0;
}

/// Soft card shadow used everywhere in the mockup.
const List<BoxShadow> kSoftShadow = [
  BoxShadow(color: Color(0x142A2420), blurRadius: 18, offset: Offset(0, 6)),
];

const List<BoxShadow> kAccentShadow = [
  BoxShadow(color: Color(0x4DDD5B35), blurRadius: 18, offset: Offset(0, 8)),
];

ThemeData buildLinkTheme() {
  final base = ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: LinkColors.accent,
      primary: LinkColors.accent,
      surface: LinkColors.card,
      error: LinkColors.err,
      brightness: Brightness.light,
    ),
    scaffoldBackgroundColor: LinkColors.background,
    fontFamily: 'Outfit',
    splashFactory: NoSplash.splashFactory,
  );

  return base.copyWith(
    textTheme: base.textTheme.apply(
      bodyColor: LinkColors.text,
      displayColor: LinkColors.text,
    ),
    dividerColor: LinkColors.border,
    dividerTheme: const DividerThemeData(color: LinkColors.border, thickness: 1, space: 1),
    cardTheme: CardThemeData(
      color: LinkColors.card,
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(LinkRadii.lg),
        side: const BorderSide(color: LinkColors.border),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: LinkColors.white,
      hintStyle: const TextStyle(color: LinkColors.faint, fontSize: 13.5),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(LinkRadii.md),
        borderSide: const BorderSide(color: LinkColors.border),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(LinkRadii.md),
        borderSide: const BorderSide(color: LinkColors.border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(LinkRadii.md),
        borderSide: const BorderSide(color: LinkColors.accent, width: 1.5),
      ),
    ),
    switchTheme: SwitchThemeData(
      thumbColor: WidgetStateProperty.resolveWith(
        (states) => states.contains(WidgetState.selected) ? Colors.white : Colors.white,
      ),
      trackColor: WidgetStateProperty.resolveWith(
        (states) => states.contains(WidgetState.selected) ? LinkColors.accent : const Color(0xFFD8CEBE),
      ),
      trackOutlineColor: WidgetStateProperty.all(Colors.transparent),
    ),
    sliderTheme: const SliderThemeData(
      activeTrackColor: LinkColors.accent,
      thumbColor: LinkColors.accent,
      inactiveTrackColor: LinkColors.accentSoft,
    ),
    progressIndicatorTheme: const ProgressIndicatorThemeData(
      color: LinkColors.accent,
      linearTrackColor: LinkColors.accentSoft,
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(foregroundColor: LinkColors.accent),
    ),
  );
}

/// Headline / title styles matching the mockup typography.
class LinkText {
  static const h1 = TextStyle(fontSize: 25, fontWeight: FontWeight.w700, letterSpacing: -0.6, height: 1.15);
  static const h2 = TextStyle(fontSize: 19, fontWeight: FontWeight.w700, letterSpacing: -0.4);
  static const h3 = TextStyle(fontSize: 15.5, fontWeight: FontWeight.w700, letterSpacing: -0.2);
  static const body = TextStyle(fontSize: 13.5, color: LinkColors.text, height: 1.45);
  static const small = TextStyle(fontSize: 12.5, color: LinkColors.muted, height: 1.45);
  static const label = TextStyle(
    fontSize: 10.5,
    fontWeight: FontWeight.w700,
    letterSpacing: 1.1,
    color: LinkColors.faint,
  );
  static const pill = TextStyle(fontSize: 11.5, fontWeight: FontWeight.w700, letterSpacing: 0.2);
}
