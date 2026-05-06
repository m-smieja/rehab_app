import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static const Color _backgroundColor = Color(0xFF05050A);

  static ThemeData get darkTheme {
    final baseTextTheme = ThemeData.dark().textTheme;

    return ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: _backgroundColor,
      textTheme: TextTheme(
        displayLarge: GoogleFonts.bebasNeue(
          fontSize: 72,
          fontWeight: FontWeight.bold,
          color: Colors.white,
          letterSpacing: 2.0,
          height: 1.0,
        ),
        displayMedium: GoogleFonts.inter(
          fontSize: 32,
          fontWeight: FontWeight.w700,
          color: Colors.white,
        ),
        headlineMedium: GoogleFonts.inter(
          fontSize: 22,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
        bodyLarge: GoogleFonts.inter(
          fontSize: 16,
          color: Colors.white.withValues(alpha: 0.85),
        ),
        bodyMedium: GoogleFonts.inter(
          fontSize: 14,
          color: Colors.white.withValues(alpha: 0.7),
        ),
      ).merge(baseTextTheme.apply(
        bodyColor: Colors.white,
        displayColor: Colors.white,
      )),
      colorScheme: const ColorScheme.dark(
        surface: _backgroundColor,
        primary: Color(0xFF7C5CFF),
        secondary: Color(0xFF2A1B54),
      ),
    );
  }
}
