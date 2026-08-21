import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app_colors.dart';

class AppTextStyles {
  AppTextStyles._();

  static TextStyle get displayLg => GoogleFonts.inter(
        fontSize: 48,
        fontWeight: FontWeight.w700,
        height: 56 / 48,
        letterSpacing: -0.02 * 16,
        color: AppColors.onSurface,
      );

  static TextStyle get headlineLg => GoogleFonts.inter(
        fontSize: 32,
        fontWeight: FontWeight.w600,
        height: 40 / 32,
        letterSpacing: -0.01 * 16,
        color: AppColors.onSurface,
      );

  static TextStyle get headlineLgMobile => GoogleFonts.inter(
        fontSize: 24,
        fontWeight: FontWeight.w600,
        height: 32 / 24,
        letterSpacing: -0.01 * 16,
        color: AppColors.onSurface,
      );

  static TextStyle get headlineMd => GoogleFonts.inter(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        height: 28 / 20,
        color: AppColors.onSurface,
      );

  static TextStyle get bodyLg => GoogleFonts.inter(
        fontSize: 18,
        fontWeight: FontWeight.w400,
        height: 28 / 18,
        color: AppColors.onSurface,
      );

  static TextStyle get bodyMd => GoogleFonts.inter(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        height: 24 / 16,
        color: AppColors.onSurface,
      );

  static TextStyle get labelMd => GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        height: 20 / 14,
        letterSpacing: 0.01 * 14,
        color: AppColors.onSurface,
      );

  static TextStyle get labelSm => GoogleFonts.inter(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        height: 16 / 12,
        letterSpacing: 0.02 * 12,
        color: AppColors.onSurfaceVariant,
      );
}
