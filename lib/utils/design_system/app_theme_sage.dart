import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:coffee_beans_app/utils/design_system/app_colors_sage.dart';
import 'package:coffee_beans_app/utils/design_system/app_text_styles_sage.dart';

export 'package:coffee_beans_app/utils/design_system/app_colors_sage.dart';
export 'package:coffee_beans_app/utils/design_system/app_text_styles_sage.dart';

/// Sage theme configuration for the Coffee Beans App.
/// Adopts the central AppTheme structure with Sage-specific colors and typography.
class AppThemeSage {
  AppThemeSage._();

  /// Border radius tokens (Shared with AppTheme).
  static const double radiusDefault = 4.0;
  static const double radiusLg = 8.0;
  static const double radiusXl = 12.0;
  static const double radiusFull = 9999.0;

  static ThemeData get lightTheme {
    final textTheme = AppTextStylesSage.buildTextTheme();

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      fontFamily: GoogleFonts.plusJakartaSans().fontFamily,
      textTheme: textTheme,

      // ── Color Scheme ──
      colorScheme: const ColorScheme.light(
        primary: AppColorsSage.primary,
        primaryContainer: AppColorsSage.primaryContainer,
        onPrimary: AppColorsSage.onPrimary,
        onPrimaryContainer: AppColorsSage.onPrimaryContainer,
        secondary: AppColorsSage.secondary,
        secondaryContainer: AppColorsSage.secondaryContainer,
        onSecondaryContainer: AppColorsSage.onSecondaryContainer,
        tertiary: AppColorsSage.tertiary,
        tertiaryContainer: AppColorsSage.tertiaryContainer,
        onTertiary: AppColorsSage.onTertiary,
        onTertiaryContainer: AppColorsSage.onTertiaryContainer,
        error: AppColorsSage.error,
        errorContainer: AppColorsSage.errorContainer,
        onError: AppColorsSage.onError,
        onErrorContainer: AppColorsSage.onErrorContainer,
        surface: AppColorsSage.surface,
        onSurface: AppColorsSage.onSurface,
        onSurfaceVariant: AppColorsSage.onSurfaceVariant,
        outline: AppColorsSage.outline,
        outlineVariant: AppColorsSage.outlineVariant,
        inverseSurface: AppColorsSage.inverseSurface,
        inversePrimary: AppColorsSage.inversePrimary,
        surfaceContainerLowest: AppColorsSage.surfaceContainerLowest,
        surfaceContainerLow: AppColorsSage.surfaceContainerLow,
        surfaceContainer: AppColorsSage.surfaceContainer,
        surfaceContainerHigh: AppColorsSage.surfaceContainerHigh,
        surfaceContainerHighest: AppColorsSage.surfaceContainerHighest,
        surfaceDim: AppColorsSage.surfaceDim,
        surfaceBright: AppColorsSage.surfaceBright,
        surfaceTint: AppColorsSage.surfaceTint,
      ),

      // ── Scaffold ──
      scaffoldBackgroundColor: AppColorsSage.surfaceBackground,

      // ── AppBar ──
      appBarTheme: AppBarTheme(
        backgroundColor: AppColorsSage.surfaceBackground,
        foregroundColor: AppColorsSage.onSurface,
        elevation: 0,
        scrolledUnderElevation: 0.5,
        centerTitle: true,
        titleTextStyle: textTheme.titleLarge,
      ),

      // ── Card ──
      cardTheme: CardThemeData(
        color: AppColorsSage.surfaceCard,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusXl),
        ),
      ),

      // ── Chip ──
      chipTheme: ChipThemeData(
        backgroundColor: AppColorsSage.surfaceContainerLow,
        selectedColor: AppColorsSage.secondaryContainer,
        labelStyle: textTheme.labelMedium,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusFull),
        ),
        side: BorderSide.none,
      ),

      // ── Filled Button ──
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: AppColorsSage.primary,
          foregroundColor: AppColorsSage.onPrimary,
          textStyle: textTheme.labelLarge,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radiusLg),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
        ),
      ),

      // ── Outlined Button ──
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColorsSage.primary,
          textStyle: textTheme.labelLarge,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radiusLg),
          ),
          side: BorderSide(
            color: AppColorsSage.outlineVariant.withValues(alpha: 0.5),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
        ),
      ),

      // ── Text Button ──
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColorsSage.primary,
          textStyle: textTheme.labelLarge,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radiusLg),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
        ),
      ),

      // ── Elevated Button ──
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColorsSage.surfaceContainerLow,
          foregroundColor: AppColorsSage.primary,
          textStyle: textTheme.labelLarge,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radiusLg),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          elevation: 0,
        ).copyWith(
          elevation: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.pressed)) return 0;
            if (states.contains(WidgetState.hovered)) return 1;
            return 0;
          }),
        ),
      ),

      // ── Divider ──
      dividerTheme: const DividerThemeData(
        color: AppColorsSage.surfaceVariant,
        thickness: 1,
      ),

      // ── Input Decoration ──
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColorsSage.surfaceContainerLow,
        hintStyle: textTheme.bodyLarge?.copyWith(
          color: AppColorsSage.outline.withValues(alpha: 0.6),
        ),
        prefixIconColor: AppColorsSage.outline,
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
          borderSide: const BorderSide(color: AppColorsSage.primary, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
      ),
    );
  }
}
