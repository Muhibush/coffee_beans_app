import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Design tokens extracted from the Stitch "Kopi Essentials" design system.
///
/// Color palette follows Material 3 conventions with a warm coffee-inspired
/// palette. Typography uses Inter via Google Fonts with three semantic roles:
/// headline, body, and label.
class AppColors {
  AppColors._();

  // ── Core Brand ──────────────────────────────────────────────
  static const Color primary = Color(0xFF553722);
  static const Color primaryContainer = Color(0xFF6F4E37);
  static const Color primaryDark = Color(0xFF4A3428);
  static const Color onPrimary = Color(0xFFFFFFFF);
  static const Color onPrimaryContainer = Color(0xFFEEC1A4);
  static const Color onPrimaryFixed = Color(0xFF2D1604);
  static const Color onPrimaryFixedVariant = Color(0xFF5F402A);
  static const Color primaryFixed = Color(0xFFFFDCC6);
  static const Color primaryFixedDim = Color(0xFFEABDA0);
  static const Color inversePrimary = Color(0xFFEABDA0);

  // ── Secondary ───────────────────────────────────────────────
  static const Color secondary = Color(0xFF7A573D);
  static const Color secondaryContainer = Color(0xFFFECDAD);
  static const Color onSecondaryContainer = Color(0xFF79563C);
  static const Color onSecondaryFixed = Color(0xFF2E1503);
  static const Color onSecondaryFixedVariant = Color(0xFF603F27);
  static const Color secondaryFixed = Color(0xFFFFDCC5);
  static const Color secondaryFixedDim = Color(0xFFECBD9D);

  // ── Tertiary ────────────────────────────────────────────────
  static const Color tertiary = Color(0xFF24434B);
  static const Color tertiaryContainer = Color(0xFF3C5A63);
  static const Color onTertiary = Color(0xFFFFFFFF);
  static const Color onTertiaryContainer = Color(0xFFB0D0DB);
  static const Color onTertiaryFixed = Color(0xFF001F27);
  static const Color onTertiaryFixedVariant = Color(0xFF2D4B54);
  static const Color tertiaryFixed = Color(0xFFC8E8F3);
  static const Color tertiaryFixedDim = Color(0xFFACCCD6);

  // ── Error ───────────────────────────────────────────────────
  static const Color error = Color(0xFFBA1A1A);
  static const Color errorContainer = Color(0xFFFFDAD6);
  static const Color onError = Color(0xFFFFFFFF);
  static const Color onErrorContainer = Color(0xFF93000A);

  // ── Surfaces ────────────────────────────────────────────────
  static const Color surface = Color(0xFFFCF9F5);
  static const Color surfaceBright = Color(0xFFFCF9F5);
  static const Color surfaceBackground = Color(0xFFFBF8F4);
  static const Color surfaceCard = Color(0xFFFFFFFF);
  static const Color surfaceContainer = Color(0xFFF0EDE9);
  static const Color surfaceContainerLow = Color(0xFFF6F3EF);
  static const Color surfaceContainerHigh = Color(0xFFEAE8E4);
  static const Color surfaceContainerHighest = Color(0xFFE5E2DE);
  static const Color surfaceDim = Color(0xFFDCDAD6);
  static const Color surfaceVariant = Color(0xFFE5E2DE);
  static const Color surfaceTint = Color(0xFF79573F);

  // ── On Surface ──────────────────────────────────────────────
  static const Color onSurface = Color(0xFF1C1C1A);
  static const Color onSurfaceVariant = Color(0xFF50453E);
  static const Color onBackground = Color(0xFF1C1C1A);
  static const Color background = Color(0xFFFCF9F5);
  static const Color inverseSurface = Color(0xFF31302E);
  static const Color inverseOnSurface = Color(0xFFF3F0EC);

  // ── Outline ─────────────────────────────────────────────────
  static const Color outline = Color(0xFF82746D);
  static const Color outlineVariant = Color(0xFFD4C3BA);
}

class AppTheme {
  AppTheme._();

  /// Border radius tokens from the Stitch tailwind config.
  static const double radiusDefault = 4.0;
  static const double radiusLg = 8.0;
  static const double radiusXl = 12.0;
  static const double radiusFull = 9999.0;

  static TextTheme _buildTextTheme() {
    return TextTheme(
      // Headline Large / 24px / Bold → Editorial Headlines
      headlineLarge: GoogleFonts.inter(
        fontSize: 24,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.5,
        color: AppColors.onSurface,
      ),
      // Headline Medium
      headlineMedium: GoogleFonts.inter(
        fontSize: 20,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.25,
        color: AppColors.onSurface,
      ),
      // Headline Small
      headlineSmall: GoogleFonts.inter(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: AppColors.onSurface,
      ),
      // Title Large
      titleLarge: GoogleFonts.inter(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: AppColors.onSurface,
      ),
      // Title Medium / 16px / Semibold → Product Labels
      titleMedium: GoogleFonts.inter(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: AppColors.onSurface,
      ),
      // Title Small
      titleSmall: GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: AppColors.onSurface,
      ),
      // Body Large
      bodyLarge: GoogleFonts.inter(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        color: AppColors.onSurface,
      ),
      // Body Medium / 14px / Regular → Narrative Text
      bodyMedium: GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: AppColors.onSurfaceVariant,
      ),
      // Body Small
      bodySmall: GoogleFonts.inter(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        color: AppColors.onSurfaceVariant,
      ),
      // Label Large
      labelLarge: GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: AppColors.onSurface,
      ),
      // Label Medium
      labelMedium: GoogleFonts.inter(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        color: AppColors.onSurfaceVariant,
      ),
      // Label Small → Mono-like annotations
      labelSmall: GoogleFonts.inter(
        fontSize: 11,
        fontWeight: FontWeight.w500,
        letterSpacing: 1.5,
        color: AppColors.outline,
      ),
    );
  }

  static ThemeData get lightTheme {
    final textTheme = _buildTextTheme();

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      fontFamily: GoogleFonts.inter().fontFamily,
      textTheme: textTheme,

      // ── Color Scheme ──
      colorScheme: const ColorScheme.light(
        primary: AppColors.primary,
        primaryContainer: AppColors.primaryContainer,
        onPrimary: AppColors.onPrimary,
        onPrimaryContainer: AppColors.onPrimaryContainer,
        secondary: AppColors.secondary,
        secondaryContainer: AppColors.secondaryContainer,
        onSecondaryContainer: AppColors.onSecondaryContainer,
        tertiary: AppColors.tertiary,
        tertiaryContainer: AppColors.tertiaryContainer,
        onTertiary: AppColors.onTertiary,
        onTertiaryContainer: AppColors.onTertiaryContainer,
        error: AppColors.error,
        errorContainer: AppColors.errorContainer,
        onError: AppColors.onError,
        onErrorContainer: AppColors.onErrorContainer,
        surface: AppColors.surface,
        onSurface: AppColors.onSurface,
        onSurfaceVariant: AppColors.onSurfaceVariant,
        outline: AppColors.outline,
        outlineVariant: AppColors.outlineVariant,
        inverseSurface: AppColors.inverseSurface,
        inversePrimary: AppColors.inversePrimary,
        surfaceContainerLowest: AppColors.surfaceCard,
        surfaceContainerLow: AppColors.surfaceContainerLow,
        surfaceContainer: AppColors.surfaceContainer,
        surfaceContainerHigh: AppColors.surfaceContainerHigh,
        surfaceContainerHighest: AppColors.surfaceContainerHighest,
        surfaceDim: AppColors.surfaceDim,
        surfaceBright: AppColors.surfaceBright,
        surfaceTint: AppColors.surfaceTint,
      ),

      // ── Scaffold ──
      scaffoldBackgroundColor: AppColors.surfaceBackground,

      // ── AppBar ──
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.surfaceBackground,
        foregroundColor: AppColors.onSurface,
        elevation: 0,
        scrolledUnderElevation: 0.5,
        centerTitle: true,
        titleTextStyle: textTheme.titleLarge,
      ),

      // ── Card ──
      cardTheme: CardThemeData(
        color: AppColors.surfaceCard,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusXl),
        ),
      ),

      // ── Chip ──
      chipTheme: ChipThemeData(
        backgroundColor: AppColors.surfaceContainerLow,
        selectedColor: AppColors.primaryContainer,
        labelStyle: textTheme.labelMedium,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusFull),
        ),
        side: BorderSide.none,
      ),

      // ── Elevated Button ──
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryContainer,
          foregroundColor: AppColors.onPrimary,
          elevation: 0,
          textStyle: textTheme.labelLarge,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radiusFull),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        ),
      ),

      // ── Filled Button ──
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.primaryContainer,
          foregroundColor: AppColors.onPrimary,
          textStyle: textTheme.labelLarge,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radiusFull),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        ),
      ),

      // ── Outlined Button ──
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.primary,
          side: const BorderSide(color: AppColors.outlineVariant),
          textStyle: textTheme.labelLarge,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radiusFull),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        ),
      ),

      // ── Divider ──
      dividerTheme: const DividerThemeData(
        color: AppColors.surfaceVariant,
        thickness: 1,
      ),

      // ── Bottom Navigation ──
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: AppColors.surfaceCard,
        selectedItemColor: AppColors.primaryContainer,
        unselectedItemColor: AppColors.onSurfaceVariant,
      ),

      // ── Input Decoration ──
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surfaceContainerLow,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusLg),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusLg),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusLg),
          borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
      ),
    );
  }
}
