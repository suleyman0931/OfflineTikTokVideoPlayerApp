import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// ==========================================
// APP-WIDE COLOR PALETTE & THEME
// ==========================================
class AppColors {
  static const Color bg = Color(0xFF0A0A0F);
  static const Color surface = Color(0xFF16161F);
  static const Color surfaceAlt = Color(0xFF1E1E29);
  static const Color primary = Color(0xFFFF2E63);
  static const Color primaryDeep = Color(0xFFB0006E);
  static const Color secondary = Color(0xFF6C5CE7);
  static const Color textPrimary = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xFFA0A0B2);

  static const LinearGradient brandGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [primary, secondary],
  );
}

class AppTheme {
  static ThemeData get darkTheme {
    final baseTextTheme = GoogleFonts.interTextTheme(ThemeData.dark().textTheme);
    return ThemeData.dark().copyWith(
      scaffoldBackgroundColor: AppColors.bg,
      colorScheme: const ColorScheme.dark(
        primary: AppColors.primary,
        secondary: AppColors.secondary,
        surface: AppColors.surface,
      ),
      textTheme: baseTextTheme,
      splashFactory: InkRipple.splashFactory,
    );
  }
}
