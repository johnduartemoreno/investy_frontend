import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app_dimens.dart';

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
        fontSize: 28, fontWeight: FontWeight.w700,
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
        fontSize: 11, fontWeight: FontWeight.w600, letterSpacing: 0.5,
      ),
    );
  }

  // Light palette — surfaces
  static const lightSurface        = Color(0xFFF8F8FC); // scaffold
  static const lightCard           = Color(0xFFEEEDF8); // surfaceContainerHigh (cards)
  static const lightCardLow        = Color(0xFFF3F2FB); // surfaceContainerLow
  static const lightContainer      = Color(0xFFE8E6F8); // surfaceContainer
  static const lightOnSurface      = Color(0xFF1C1B1F);
  static const lightOnSurfaceVar   = Color(0xFF605D6E);
  static const lightOutline        = Color(0xFFC4C0D4);
  static const lightOutlineVariant = Color(0xFFE2DFF0);

  static final lightTheme = ThemeData(
    useMaterial3: true,
    colorScheme: const ColorScheme(
      brightness: Brightness.light,
      primary: brandPurple,
      onPrimary: Colors.white,
      primaryContainer: Color(0xFFEDE8FF),
      onPrimaryContainer: Color(0xFF3B2E8F),
      secondary: brandPurpleLight,
      onSecondary: Colors.white,
      secondaryContainer: Color(0xFFF0EBFF),
      onSecondaryContainer: Color(0xFF4A3580),
      tertiary: signalGreen,
      onTertiary: Color(0xFF0F2A1A),
      tertiaryContainer: Color(0xFFD4FAE4),
      onTertiaryContainer: Color(0xFF0F2A1A),
      error: Color(0xFFDC2626),
      onError: Colors.white,
      errorContainer: Color(0xFFFFE4E4),
      onErrorContainer: Color(0xFF8B0000),
      surface: lightSurface,
      onSurface: lightOnSurface,
      onSurfaceVariant: lightOnSurfaceVar,
      outline: lightOutline,
      outlineVariant: lightOutlineVariant,
      shadow: Colors.black,
      scrim: Colors.black,
      inverseSurface: lightOnSurface,
      onInverseSurface: lightSurface,
      inversePrimary: brandPurpleLight,
      surfaceContainerLowest: Colors.white,
      surfaceContainerLow: lightCardLow,
      surfaceContainer: lightContainer,
      surfaceContainerHigh: lightCard,
      surfaceContainerHighest: Color(0xFFE2DFF2),
    ),
    scaffoldBackgroundColor: lightSurface,
    textTheme: _buildTextTheme(ThemeData.light().textTheme),
    appBarTheme: AppBarTheme(
      backgroundColor: lightSurface,
      surfaceTintColor: Colors.transparent,
      centerTitle: true,
      elevation: 0,
      titleTextStyle: GoogleFonts.dmSans(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: lightOnSurface,
      ),
    ),
    cardTheme: CardThemeData(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppDimens.radiusCard),
        side: const BorderSide(color: lightOutlineVariant, width: 1),
      ),
    ),
    dividerTheme: const DividerThemeData(
      color: lightOutlineVariant,
      thickness: 1,
    ),
    inputDecorationTheme: InputDecorationTheme(
      fillColor: Colors.white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppDimens.radiusInput),
        borderSide: const BorderSide(color: lightOutlineVariant, width: 1),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppDimens.radiusInput),
        borderSide: const BorderSide(color: lightOutlineVariant, width: 1),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppDimens.radiusInput),
        borderSide: const BorderSide(color: brandPurple, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppDimens.radiusInput),
        borderSide: const BorderSide(color: Color(0xFFDC2626), width: 1),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppDimens.radiusInput),
        borderSide: const BorderSide(color: Color(0xFFDC2626), width: 2),
      ),
      filled: true,
    ),
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: lightSurface,
      elevation: 0,
      indicatorColor: brandPurple.withValues(alpha: 0.15),
      iconTheme: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return const IconThemeData(color: brandPurple);
        }
        return const IconThemeData(color: lightOnSurfaceVar);
      }),
      labelTextStyle: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return GoogleFonts.dmSans(
              color: brandPurple, fontWeight: FontWeight.w700, fontSize: 12);
        }
        return GoogleFonts.dmSans(color: lightOnSurfaceVar, fontSize: 12);
      }),
    ),
  );

  // Brand palette
  static const brandPurple = Color(0xFF6C63FF);
  static const brandPurpleLight = Color(0xFFa78bfa);

  // Semantic signal colors (badges: Strong buy, Moderate, Sell)
  static const signalGreen = Color(0xFF4ade80);
  static const signalGreenContainer = Color(0xFF0F2A1A);
  static const signalAmber = Color(0xFFD97706);
  static const signalAmberContainer = Color(0xFF2A1A00);

  // Layered dark surfaces
  static const darkBase = Color(0xFF0F0F13);
  static const darkSurface = Color(0xFF1A1A20);
  static const darkElevated = Color(0xFF1E1C2A);
  static const darkCard = Color(0xFF242430);

  static final darkTheme = ThemeData(
    useMaterial3: true,
    colorScheme: const ColorScheme(
      brightness: Brightness.dark,
      primary: brandPurple,
      onPrimary: Colors.white,
      primaryContainer: Color(0xFF1E1B2E),
      onPrimaryContainer: brandPurpleLight,
      secondary: brandPurpleLight,
      onSecondary: Colors.white,
      secondaryContainer: Color(0xFF1A1730),
      onSecondaryContainer: brandPurpleLight,
      tertiary: Color(0xFF4ade80),
      onTertiary: Color(0xFF0F2A1A),
      tertiaryContainer: Color(0xFF0F2A1A),
      onTertiaryContainer: Color(0xFF4ade80),
      error: Color(0xFFf87171),
      onError: Colors.white,
      errorContainer: Color(0xFF2A1010),
      onErrorContainer: Color(0xFFf87171),
      surface: darkBase,
      onSurface: Colors.white,
      onSurfaceVariant: Color(0xFF9090A8),
      outline: Color(0xFF3A3A50),
      outlineVariant: Color(0xFF2A2A38),
      shadow: Colors.black,
      scrim: Colors.black,
      inverseSurface: Colors.white,
      onInverseSurface: darkBase,
      inversePrimary: brandPurple,
      surfaceContainerLowest: darkBase,
      surfaceContainerLow: darkSurface,
      surfaceContainer: darkElevated,
      surfaceContainerHigh: darkCard,
      surfaceContainerHighest: Color(0xFF2E2E3E),
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
        borderRadius: BorderRadius.circular(AppDimens.radiusCard),
        side: const BorderSide(color: Color(0xFF2A2A38), width: 1),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      fillColor: darkSurface,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppDimens.radiusInput),
        borderSide: const BorderSide(color: Color(0xFF3A3A50)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppDimens.radiusInput),
        borderSide: const BorderSide(color: Color(0xFF3A3A50)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppDimens.radiusInput),
        borderSide: const BorderSide(color: brandPurple, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppDimens.radiusInput),
        borderSide: const BorderSide(color: Color(0xFFf87171), width: 1),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppDimens.radiusInput),
        borderSide: const BorderSide(color: Color(0xFFf87171), width: 2),
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
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: darkBase,
      elevation: 0,
      indicatorColor: brandPurple.withValues(alpha: 0.2),
      iconTheme: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return const IconThemeData(color: brandPurple);
        }
        return const IconThemeData(color: Color(0xFF9090A8));
      }),
      labelTextStyle: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return GoogleFonts.dmSans(
              color: brandPurple, fontWeight: FontWeight.w700, fontSize: 12);
        }
        return GoogleFonts.dmSans(
            color: const Color(0xFF9090A8), fontSize: 12);
      }),
    ),
  );
}
