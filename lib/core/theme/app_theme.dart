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

  // Brand palette
  static const brandPurple = Color(0xFF6C63FF);
  static const brandPurpleLight = Color(0xFFa78bfa);

  // Layered dark surfaces
  static const darkBase = Color(0xFF0F0F13);
  static const darkSurface = Color(0xFF1A1A20);
  static const darkElevated = Color(0xFF1E1C2A);
  static const darkCard = Color(0xFF242430);

  static final darkTheme = ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme(
      brightness: Brightness.dark,
      primary: brandPurple,
      onPrimary: Colors.white,
      primaryContainer: const Color(0xFF1E1B2E),
      onPrimaryContainer: brandPurpleLight,
      secondary: brandPurpleLight,
      onSecondary: Colors.white,
      secondaryContainer: const Color(0xFF1A1730),
      onSecondaryContainer: brandPurpleLight,
      tertiary: const Color(0xFF4ade80),
      onTertiary: const Color(0xFF0F2A1A),
      tertiaryContainer: const Color(0xFF0F2A1A),
      onTertiaryContainer: const Color(0xFF4ade80),
      error: const Color(0xFFf87171),
      onError: Colors.white,
      errorContainer: const Color(0xFF2A1010),
      onErrorContainer: const Color(0xFFf87171),
      surface: darkBase,
      onSurface: Colors.white,
      onSurfaceVariant: const Color(0xFF9090A8),
      outline: const Color(0xFF3A3A50),
      outlineVariant: const Color(0xFF2A2A38),
      shadow: Colors.black,
      scrim: Colors.black,
      inverseSurface: Colors.white,
      onInverseSurface: darkBase,
      inversePrimary: brandPurple,
      surfaceContainerLowest: darkBase,
      surfaceContainerLow: darkSurface,
      surfaceContainer: darkElevated,
      surfaceContainerHigh: darkCard,
      surfaceContainerHighest: const Color(0xFF2E2E3E),
    ),
    scaffoldBackgroundColor: darkBase,
    textTheme: _buildTextTheme(ThemeData.dark().textTheme),
    appBarTheme: AppBarTheme(
      backgroundColor: darkBase,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      centerTitle: true,
      titleTextStyle: GoogleFonts.dmSans(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: Colors.white,
      ),
    ),
    cardTheme: CardThemeData(
      color: darkSurface,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: const BorderSide(color: Color(0xFF2A2A38), width: 1),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      fillColor: darkSurface,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFF3A3A50)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFF3A3A50)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: brandPurple, width: 1.5),
      ),
      filled: true,
    ),
    dividerTheme: const DividerThemeData(
      color: Color(0xFF2A2A38),
      thickness: 1,
    ),
    bottomSheetTheme: const BottomSheetThemeData(
      backgroundColor: darkElevated,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
    ),
  );
}
