import 'package:flutter/material.dart';

// One place for the look of the whole app.
class AppTheme {
  static const Color lightAccent = Color(0xFFC62828);
  static const Color darkAccent = Color(0xFFEF5350);

  // Fade page transition on every platform.
  static const _transitions = PageTransitionsTheme(builders: {
    TargetPlatform.android: FadeUpwardsPageTransitionsBuilder(),
    TargetPlatform.iOS: FadeUpwardsPageTransitionsBuilder(),
    TargetPlatform.windows: FadeUpwardsPageTransitionsBuilder(),
    TargetPlatform.macOS: FadeUpwardsPageTransitionsBuilder(),
    TargetPlatform.linux: FadeUpwardsPageTransitionsBuilder(),
  });

  static final _buttonShape =
      RoundedRectangleBorder(borderRadius: BorderRadius.circular(12));
  static const _buttonPadding =
      EdgeInsets.symmetric(horizontal: 20, vertical: 14);

  // Light theme: white background + black text = clear in B&W print.
  static final ThemeData light = ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(seedColor: lightAccent).copyWith(
      primary: lightAccent,
      onPrimary: Colors.white,
      surface: Colors.white,
      onSurface: Colors.black,
      outline: Colors.black,
    ),
    scaffoldBackgroundColor: Colors.white,
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.white,
      foregroundColor: Colors.black,
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: false,
      titleTextStyle: TextStyle(
          color: Colors.black, fontSize: 20, fontWeight: FontWeight.w800),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: lightAccent,
        foregroundColor: Colors.white,
        padding: _buttonPadding,
        shape: _buttonShape,
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: Colors.black,
        side: const BorderSide(color: Colors.black),
        padding: _buttonPadding,
        shape: _buttonShape,
      ),
    ),
    pageTransitionsTheme: _transitions,
  );

  static final ThemeData dark = ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: lightAccent,
      brightness: Brightness.dark,
    ).copyWith(
      primary: darkAccent,
      onPrimary: Colors.black,
      surface: const Color(0xFF121216),
      onSurface: Colors.white,
    ),
    scaffoldBackgroundColor: const Color(0xFF0E0E11),
    appBarTheme: const AppBarTheme(
      backgroundColor: Color(0xFF0E0E11),
      foregroundColor: Colors.white,
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: false,
      titleTextStyle: TextStyle(
          color: Colors.white, fontSize: 20, fontWeight: FontWeight.w800),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: darkAccent,
        foregroundColor: Colors.black,
        padding: _buttonPadding,
        shape: _buttonShape,
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: Colors.white,
        side: const BorderSide(color: Colors.white70),
        padding: _buttonPadding,
        shape: _buttonShape,
      ),
    ),
    pageTransitionsTheme: _transitions,
  );

  // ---------- Small helpers used by many widgets ----------
  static Color cardColor(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark
          ? const Color(0xFF1C1C22)
          : Colors.white;

  static Color mutedText(BuildContext context) =>
      Theme.of(context).colorScheme.onSurface.withAlpha(170);

  // Same look for every text field.
  static InputDecoration inputDeco(String label,
      {IconData? icon, String? hint, Widget? suffix}) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      prefixIcon: icon == null ? null : Icon(icon),
      suffixIcon: suffix,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
    );
  }
}
