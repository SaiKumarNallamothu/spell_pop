import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  AppTheme._();

  // Vibrant accent colors (Spell Pop inspired)
  static const Color primaryColor = Color(0xff6366f1); // Indigo / Electric Purple
  static const Color primaryGradientEnd = Color(0xff8b5cf6); // Soft Purple
  static const Color coralPink = Color(0xffff5e7e); // Coral / vibrant pop pink
  static const Color sunnyYellow = Color(0xffffb800); // Sunny warm amber / gold
  static const Color mintGreen = Color(0xff10b981); // Bright mint
  static const Color tealAccent = Color(0xff06b6d4); // Vibrant teal
  static const Color skyBlue = Color(0xff38bdf8); // Sky blue
  static const Color orangePop = Color(0xfff97316); // Juicy orange

  // Aliases for compatibility
  static const Color secondaryColor = sunnyYellow;
  static const Color successColor = mintGreen;
  static const Color errorColor = Color(0xfff43f5e); // Rose red

  // Light Theme Palette (2025 Pastel Aesthetic)
  static const Color lightBackgroundColor = Color(0xfff5f7fb); // Creamy soft pastel slate
  static const Color lightSurfaceColor = Colors.white;
  static const Color lightTextPrimary = Color(0xff1e1b4b); // Deep indigo night (high contrast, friendly)
  static const Color lightTextSecondary = Color(0xff64748b); // Muted slate

  // Pastel Card background tints
  static const Color pastelMint = Color(0xffecfdf5);
  static const Color pastelPeach = Color(0xfffff1f2);
  static const Color pastelLavender = Color(0xfff3e8ff);
  static const Color pastelSky = Color(0xffe0f2fe);
  static const Color pastelYellow = Color(0xfffef9c3);

  // Dark Theme Palette
  static const Color darkBackgroundColor = Color(0xff0f111a); // Rich midnight
  static const Color darkSurfaceColor = Color(0xff1a1d2e); // Deep slate violet
  static const Color darkTextPrimary = Color(0xfff8fafc);
  static const Color darkTextSecondary = Color(0xff94a3b8);

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: const ColorScheme.light(
        primary: primaryColor,
        secondary: secondaryColor,
        error: errorColor,
        surface: lightSurfaceColor,
        onSurface: lightTextPrimary,
      ),
      scaffoldBackgroundColor: lightBackgroundColor,
      cardTheme: const CardThemeData(
        color: lightSurfaceColor,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(24)),
        ),
      ),
      textTheme: GoogleFonts.fredokaTextTheme().copyWith(
        displayLarge: GoogleFonts.fredoka(
          fontSize: 34,
          fontWeight: FontWeight.w700,
          color: lightTextPrimary,
          letterSpacing: -0.5,
        ),
        displayMedium: GoogleFonts.fredoka(
          fontSize: 26,
          fontWeight: FontWeight.w600,
          color: lightTextPrimary,
        ),
        titleMedium: GoogleFonts.fredoka(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: lightTextPrimary,
        ),
        bodyLarge: GoogleFonts.nunito(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: lightTextPrimary,
        ),
        bodyMedium: GoogleFonts.nunito(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: lightTextSecondary,
        ),
      ),
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: const ColorScheme.dark(
        primary: primaryColor,
        secondary: secondaryColor,
        error: errorColor,
        surface: darkSurfaceColor,
        onSurface: darkTextPrimary,
      ),
      scaffoldBackgroundColor: darkBackgroundColor,
      cardTheme: const CardThemeData(
        color: darkSurfaceColor,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(24)),
        ),
      ),
      textTheme: GoogleFonts.fredokaTextTheme(ThemeData.dark().textTheme).copyWith(
        displayLarge: GoogleFonts.fredoka(
          fontSize: 34,
          fontWeight: FontWeight.w700,
          color: darkTextPrimary,
          letterSpacing: -0.5,
        ),
        displayMedium: GoogleFonts.fredoka(
          fontSize: 26,
          fontWeight: FontWeight.w600,
          color: darkTextPrimary,
        ),
        titleMedium: GoogleFonts.fredoka(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: darkTextPrimary,
        ),
        bodyLarge: GoogleFonts.nunito(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: darkTextPrimary,
        ),
        bodyMedium: GoogleFonts.nunito(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: darkTextSecondary,
        ),
      ),
    );
  }
}

extension ColorSchemeSuccess on ColorScheme {
  Color get success => AppTheme.successColor;
}
