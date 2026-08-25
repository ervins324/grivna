import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

class AppTypography {
  AppTypography._();

  static TextStyle get displayLarge => GoogleFonts.spaceGrotesk(
        fontSize: 38,
        fontWeight: FontWeight.w700,
        letterSpacing: -1.2,
        color: AppColors.textPrimary,
      );

  static TextStyle get displayMedium => GoogleFonts.spaceGrotesk(
        fontSize: 30,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.8,
        color: AppColors.textPrimary,
      );

  static TextStyle get displaySmall => GoogleFonts.spaceGrotesk(
        fontSize: 24,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.5,
        color: AppColors.textPrimary,
      );

  static TextStyle get titleLarge => GoogleFonts.inter(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.3,
        color: AppColors.textPrimary,
      );

  static TextStyle get titleMedium => GoogleFonts.inter(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimary,
      );

  static TextStyle get bodyLarge => GoogleFonts.inter(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        color: AppColors.textPrimary,
      );

  static TextStyle get bodyMedium => GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: AppColors.textSecondary,
      );

  static TextStyle get bodySmall => GoogleFonts.inter(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        color: AppColors.textTertiary,
      );

  static TextStyle get monoAmount => GoogleFonts.robotoMono(
        fontSize: 26,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.5,
        color: AppColors.textPrimary,
      );

  static TextStyle get monoSmall => GoogleFonts.robotoMono(
        fontSize: 13,
        fontWeight: FontWeight.w500,
        color: AppColors.textSecondary,
      );
}
