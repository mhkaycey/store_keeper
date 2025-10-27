import 'package:flutter/material.dart';

import 'package:shadcn_ui/shadcn_ui.dart';

class AppTheme {
  static ShadThemeData get lightTheme {
    return ShadThemeData(
      colorScheme: ShadZincColorScheme.light(),
      secondaryBadgeTheme: ShadBadgeTheme(
        backgroundColor: const Color(0xFF0066CC),
        foregroundColor: Colors.white,
      ),
    );
  }

  static ThemeData get materialTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.light(
        primary: const Color(0xFF0066CC),
        secondary: const Color(0xFF6B7280),
        surface: Colors.white,
      ),
      // fontFamily: GoogleFonts.inter().fontFamily,
      cardTheme: CardThemeData(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
        ),
        filled: true,
        fillColor: const Color(0xFFF9FAFB),
      ),
    );
  }
}
