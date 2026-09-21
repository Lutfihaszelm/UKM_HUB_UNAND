import 'package:flutter/material.dart';

/// Color tokens extracted from the UKM Hub Unand Figma design
/// (Splash & Login screens, dark theme).
class AppColors {
  AppColors._();

  // Background gradient (top teal -> bottom navy)
  static const Color bgGradientTop = Color(0xFF0A2E29);
  static const Color bgGradientBottom = Color(0xFF101B30);

  // Surfaces
  static const Color surfaceCard = Color(0xFF16262E);
  static const Color surfaceInput = Color(0xFF1C2E38);
  static const Color surfaceFooter = Color(0xFF081018);

  // Borders
  static const Color borderSubtle = Color(0x26FFFFFF); // white @ 15%
  static const Color borderInput = Color(0x1FFFFFFF); // white @ 12%

  // Brand green (gradient button / accents)
  static const Color primaryGreenLight = Color(0xFF6FF0C1);
  static const Color primaryGreenDark = Color(0xFF17B978);
  static const Color accentGreen = Color(0xFF4ADE9C);

  // Text
  static const Color textPrimary = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xFF9FB4C2);
  static const Color textLabel = Color(0xFFB6C6D1);
  static const Color textPlaceholder = Color(0xFF6C8494);
  static const Color textOnButton = Color(0xFF0A2B24);
  static const Color textFooter = Color(0xFF7A8B98);

  // Misc
  static const Color iconMuted = Color(0xFF8FA4B2);
  static const Color accentGold = Color(0xFFE7B968);
  static const Color error = Color(0xFFEF5A5A);

  static const LinearGradient backgroundGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [bgGradientTop, bgGradientBottom],
  );

  static const LinearGradient primaryButtonGradient = LinearGradient(
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    colors: [primaryGreenLight, primaryGreenDark],
  );
}
