import 'package:flutter/material.dart';
import 'app_theme.dart';

// Extra polish layered on top of your existing AppTheme.
class PolishedTheme {
  static ThemeData get light => _polish(AppTheme.light, isDark: false);
  static ThemeData get dark => _polish(AppTheme.dark, isDark: true);

  static ThemeData _polish(ThemeData base, {required bool isDark}) {
    final cs = base.colorScheme;
    final border = isDark ? Colors.white24 : Colors.black26;

    return base.copyWith(
      // Softer, more readable text.
      textTheme: base.textTheme.copyWith(
        headlineSmall:
            base.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800),
        titleLarge:
            base.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
        titleMedium:
            base.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
        bodyMedium: base.textTheme.bodyMedium?.copyWith(height: 1.4),
      ),

      // Rounded, clean text fields.
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: isDark ? const Color(0xFF1C1C22) : const Color(0xFFF7F7F7),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: cs.primary, width: 2),
        ),
      ),

      // Bottom bar and side rail.
      navigationBarTheme: NavigationBarThemeData(
        height: 68,
        elevation: 0,
        backgroundColor: isDark ? const Color(0xFF121216) : Colors.white,
        indicatorColor: cs.primary.withAlpha(isDark ? 70 : 28),
        labelTextStyle: WidgetStateProperty.resolveWith((s) => TextStyle(
              fontSize: 12,
              fontWeight:
                  s.contains(WidgetState.selected) ? FontWeight.w800 : FontWeight.w500,
            )),
      ),
      navigationRailTheme: NavigationRailThemeData(
        backgroundColor: isDark ? const Color(0xFF121216) : Colors.white,
        indicatorColor: cs.primary.withAlpha(isDark ? 70 : 28),
        selectedLabelTextStyle:
            const TextStyle(fontWeight: FontWeight.w800),
      ),

      // Pill-shaped genre chips.
      chipTheme: base.chipTheme.copyWith(
        shape: const StadiumBorder(),
        side: BorderSide(color: border),
        labelStyle: const TextStyle(fontWeight: FontWeight.w600),
      ),

      // Floating, rounded snack bars.
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),

      // Slider and switches use the accent colour.
      sliderTheme: base.sliderTheme.copyWith(
        activeTrackColor: cs.primary,
        thumbColor: cs.primary,
        trackHeight: 4,
      ),

      // Subtle dividers.
      dividerTheme: DividerThemeData(color: border, space: 1, thickness: 0.8),
    );
  }
}
