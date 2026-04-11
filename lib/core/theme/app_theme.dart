import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Typography system: DM Sans throughout — clean, consistent, modern fintech.
/// All roles use DM Sans with weight/size hierarchy for visual structure.
class AppTheme {
  // DM Sans base — applied to all text roles uniformly
  static TextTheme _buildTextTheme(TextTheme base) {
    final dmSans = GoogleFonts.dmSansTextTheme(base);
    return dmSans.copyWith(
      displayLarge: GoogleFonts.dmSans(
        fontSize: 57, fontWeight: FontWeight.w700, letterSpacing: -0.25,
      ),
      displayMedium: GoogleFonts.dmSans(
        fontSize: 45, fontWeight: FontWeight.w700,
      ),
      displaySmall: GoogleFonts.dmSans(
        fontSize: 36, fontWeight: FontWeight.w600,
      ),
      headlineLarge: GoogleFonts.dmSans(
        fontSize: 32, fontWeight: FontWeight.w600,
      ),
      headlineMedium: GoogleFonts.dmSans(
        fontSize: 28, fontWeight: FontWeight.w600,
      ),
      headlineSmall: GoogleFonts.dmSans(
        fontSize: 24, fontWeight: FontWeight.w600,
      ),
      titleLarge: GoogleFonts.dmSans(
        fontSize: 22, fontWeight: FontWeight.w600,
      ),
      titleMedium: GoogleFonts.dmSans(
        fontSize: 16, fontWeight: FontWeight.w600, letterSpacing: 0.15,
      ),
      titleSmall: GoogleFonts.dmSans(
        fontSize: 14, fontWeight: FontWeight.w500, letterSpacing: 0.1,
      ),
      bodyLarge: GoogleFonts.dmSans(
        fontSize: 16, fontWeight: FontWeight.w400, letterSpacing: 0.5,
      ),
      bodyMedium: GoogleFonts.dmSans(
        fontSize: 14, fontWeight: FontWeight.w400, letterSpacing: 0.25,
      ),
      bodySmall: GoogleFonts.dmSans(
        fontSize: 12, fontWeight: FontWeight.w400, letterSpacing: 0.4,
      ),
      labelLarge: GoogleFonts.dmSans(
        fontSize: 14, fontWeight: FontWeight.w600, letterSpacing: 0.1,
      ),
      labelMedium: GoogleFonts.dmSans(
        fontSize: 12, fontWeight: FontWeight.w500, letterSpacing: 0.5,
      ),
      labelSmall: GoogleFonts.dmSans(
        fontSize: 11, fontWeight: FontWeight.w500, letterSpacing: 0.5,
      ),
    );
  }

  static final lightTheme = ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: const Color(0xFF6750A4),
      brightness: Brightness.light,
    ),
    textTheme: _buildTextTheme(ThemeData.light().textTheme),
    appBarTheme: AppBarTheme(
      centerTitle: true,
      titleTextStyle: GoogleFonts.dmSans(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: const Color(0xFF1C1B1F),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      filled: true,
    ),
  );

  static final darkTheme = ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: const Color(0xFF6750A4),
      brightness: Brightness.dark,
    ),
    textTheme: _buildTextTheme(ThemeData.dark().textTheme),
    appBarTheme: AppBarTheme(
      centerTitle: true,
      titleTextStyle: GoogleFonts.dmSans(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: Colors.white,
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      filled: true,
    ),
  );
}
