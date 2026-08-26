import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

class AppTypography {
  AppTypography._();

  static String currentFontFamily = 'Space Grotesk';

  static TextStyle get displayLarge => GoogleFonts.getFont(
        currentFontFamily,
        fontSize: 38,
        fontWeight: FontWeight.w700,
        letterSpacing: -1.2,
        color: AppColors.textPrimary,
      );

  static TextStyle get displayMedium => GoogleFonts.getFont(
        currentFontFamily,
        fontSize: 30,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.8,
        color: AppColors.textPrimary,
      );

  static TextStyle get displaySmall => GoogleFonts.getFont(
        currentFontFamily,
        fontSize: 24,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.5,
        color: AppColors.textPrimary,
      );

  static TextStyle get titleLarge => GoogleFonts.getFont(
        currentFontFamily,
        fontSize: 20,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.3,
        color: AppColors.textPrimary,
      );

  static TextStyle get titleMedium => GoogleFonts.getFont(
        currentFontFamily,
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimary,
      );

  static TextStyle get bodyLarge => GoogleFonts.getFont(
        currentFontFamily,
        fontSize: 16,
        fontWeight: FontWeight.w400,
        color: AppColors.textPrimary,
      );

  static TextStyle get bodyMedium => GoogleFonts.getFont(
        currentFontFamily,
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: AppColors.textSecondary,
      );

  static TextStyle get bodySmall => GoogleFonts.getFont(
        currentFontFamily,
        fontSize: 12,
        fontWeight: FontWeight.w400,
        color: AppColors.textTertiary,
      );

  static TextStyle get monoAmount => GoogleFonts.getFont(
        currentFontFamily == 'Space Grotesk' ||
                currentFontFamily == 'JetBrains Mono' ||
                currentFontFamily == 'Fira Code'
            ? currentFontFamily
            : 'Roboto Mono',
        fontSize: 26,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.5,
        color: AppColors.textPrimary,
      );

  static TextStyle get monoSmall => GoogleFonts.getFont(
        currentFontFamily == 'Space Grotesk' ||
                currentFontFamily == 'JetBrains Mono' ||
                currentFontFamily == 'Fira Code'
            ? currentFontFamily
            : 'Roboto Mono',
        fontSize: 13,
        fontWeight: FontWeight.w500,
        color: AppColors.textSecondary,
      );
}
