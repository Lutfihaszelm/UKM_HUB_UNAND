import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app_colors.dart';

/// Typography tokens. Font family is an approximation (Plus Jakarta Sans)
/// of the geometric sans used in the Figma design — swap via
/// [_fontFamily] once the exact family is confirmed from Figma Dev Mode.
class AppTextStyles {
  AppTextStyles._();

  static TextStyle _base({
    required double fontSize,
    required FontWeight fontWeight,
    Color color = AppColors.textPrimary,
    double? letterSpacing,
    double? height,
  }) {
    return GoogleFonts.plusJakartaSans(
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: color,
      letterSpacing: letterSpacing,
      height: height,
    );
  }

  // Headings
  static TextStyle get h1 => _base(fontSize: 26, fontWeight: FontWeight.w700);
  static TextStyle get h2 => _base(fontSize: 22, fontWeight: FontWeight.w700);

  // Body
  static TextStyle get bodyRegular =>
      _base(fontSize: 14, fontWeight: FontWeight.w400, color: AppColors.textSecondary);
  static TextStyle get bodyMedium =>
      _base(fontSize: 14, fontWeight: FontWeight.w500);

  // Labels / inputs
  static TextStyle get label =>
      _base(fontSize: 12.5, fontWeight: FontWeight.w500, color: AppColors.textLabel);
  static TextStyle get inputText =>
      _base(fontSize: 14.5, fontWeight: FontWeight.w500);
  static TextStyle get inputPlaceholder =>
      _base(fontSize: 14.5, fontWeight: FontWeight.w400, color: AppColors.textPlaceholder);

  // Buttons / links
  static TextStyle get button =>
      _base(fontSize: 15.5, fontWeight: FontWeight.w700, color: AppColors.textOnButton);
  static TextStyle get buttonSecondary =>
      _base(fontSize: 14.5, fontWeight: FontWeight.w600);
  static TextStyle get link =>
      _base(fontSize: 13.5, fontWeight: FontWeight.w600, color: AppColors.accentGreen);

  // Footer / caption
  static TextStyle get caption =>
      _base(fontSize: 11.5, fontWeight: FontWeight.w400, color: AppColors.textFooter);
  static TextStyle get badge =>
      _base(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.accentGreen);
}
