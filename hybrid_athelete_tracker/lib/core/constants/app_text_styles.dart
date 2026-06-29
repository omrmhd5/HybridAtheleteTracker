import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

/// Typography tokens — DM Sans, matching the design system type scale.
class AppTextStyles {
  // ── Semantic text roles ───────────────────
  static TextStyle get heading1 => GoogleFonts.dmSans(
    fontSize: 26,
    fontWeight: FontWeight.w700,
    height: 1.2,
    letterSpacing: -0.4,
    color: AppColors.textPrimary,
  );

  static TextStyle get heading2 => GoogleFonts.dmSans(
    fontSize: 22,
    fontWeight: FontWeight.w700,
    height: 1.2,
    color: AppColors.textPrimary,
  );

  static TextStyle get heading3 => GoogleFonts.dmSans(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    height: 1.2,
    color: AppColors.textPrimary,
  );

  static TextStyle get bodyLarge => GoogleFonts.dmSans(
    fontSize: 15,
    fontWeight: FontWeight.w400,
    height: 1.5,
    color: AppColors.textPrimary,
  );

  static TextStyle get bodyMedium => GoogleFonts.dmSans(
    fontSize: 13,
    fontWeight: FontWeight.w400,
    height: 1.5,
    color: AppColors.textSecondary,
  );

  static TextStyle get caption => GoogleFonts.dmSans(
    fontSize: 11,
    fontWeight: FontWeight.w500,
    height: 1.5,
    color: AppColors.textMuted,
  );

  /// Convenience: DM Sans at an arbitrary size/weight/color.
  static TextStyle sans({
    double size = 15,
    FontWeight weight = FontWeight.w400,
    Color? color,
    double? height,
    double? letterSpacing,
  }) => GoogleFonts.dmSans(
    fontSize: size,
    fontWeight: weight,
    color: color ?? AppColors.textPrimary,
    height: height,
    letterSpacing: letterSpacing,
  );
}
