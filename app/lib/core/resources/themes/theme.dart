import 'package:flutter/material.dart';
import 'package:forui/forui.dart';

/// Accent colour the coach picks in Settings. Every variant exists in a light
/// and a dark flavour; the dark surfaces carry a faint tint of the accent so
/// each combination has its own mood rather than one grey with a coloured
/// button.
enum AppAccent {
  blue(
    label: 'Blue',
    light: Color(0xFF2A85F2),
    dark: Color(0xFF2B8CFF),
    lightBackground: Color(0xFFF3F6FA),
    darkBackground: Color(0xFF0F1521),
    darkCard: Color(0xFF161E2C),
    darkBorder: Color(0xFF263245),
  ),
  green(
    label: 'Green',
    light: Color(0xFF34A853),
    dark: Color(0xFF2FD172),
    lightBackground: Color(0xFFF2F7F3),
    darkBackground: Color(0xFF0E1712),
    darkCard: Color(0xFF14211A),
    darkBorder: Color(0xFF22362A),
  ),
  orange(
    label: 'Orange',
    light: Color(0xFFFF5A1F),
    dark: Color(0xFFFF6A1A),
    lightBackground: Color(0xFFFBF5F1),
    darkBackground: Color(0xFF141414),
    darkCard: Color(0xFF1C1C1C),
    darkBorder: Color(0xFF2E2E2E),
  ),
  purple(
    label: 'Purple',
    light: Color(0xFF7449F5),
    dark: Color(0xFF8250FF),
    lightBackground: Color(0xFFF5F4FA),
    darkBackground: Color(0xFF12121C),
    darkCard: Color(0xFF1A1A28),
    darkBorder: Color(0xFF2A2A3D),
  );

  const AppAccent({
    required this.label,
    required this.light,
    required this.dark,
    required this.lightBackground,
    required this.darkBackground,
    required this.darkCard,
    required this.darkBorder,
  });

  final String label;
  final Color light;
  final Color dark;
  final Color lightBackground;
  final Color darkBackground;
  final Color darkCard;
  final Color darkBorder;

  static const fallback = AppAccent.blue;
}

final _themeCache = <(AppAccent, bool), FThemeData>{};

/// ForUI theme for the given accent and brightness; the Material theme is
/// derived from it via `toApproximateMaterialTheme()`.
///
/// Built through the [FThemeData] factory rather than `copyWith(colors:)`:
/// widget styles (buttons, cards, …) are resolved from the colours at
/// construction time, so a `copyWith` would leave them on zinc's palette.
FThemeData buildForUiTheme(AppAccent accent, {required bool dark}) =>
    _themeCache.putIfAbsent((accent, dark), () {
      return FThemeData(
        touch: true,
        colors: dark ? _darkColors(accent) : _lightColors(accent),
      );
    });

FColors _darkColors(AppAccent accent) {
  final raised = Color.lerp(accent.darkCard, Colors.white, 0.05)!;
  return FThemes.zinc.dark.touch.colors.copyWith(
    background: accent.darkBackground,
    foreground: Colors.white,
    primary: accent.dark,
    primaryForeground: Colors.white,
    secondary: raised,
    secondaryForeground: Colors.white,
    muted: raised,
    mutedForeground: const Color(0xFF9AA1AD),
    card: accent.darkCard,
    border: accent.darkBorder,
  );
}

FColors _lightColors(AppAccent accent) =>
    FThemes.zinc.light.touch.colors.copyWith(
      background: accent.lightBackground,
      foreground: const Color(0xFF1E1E1E),
      primary: accent.light,
      primaryForeground: Colors.white,
      secondary: const Color(0xFFF4F5F7),
      secondaryForeground: const Color(0xFF1E1E1E),
      muted: const Color(0xFFF4F5F7),
      card: Colors.white,
      border: const Color(0xFFE3E6EB),
    );
