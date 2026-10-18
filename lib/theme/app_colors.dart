import 'package:flutter/material.dart';

/// Color tokens extracted from the UKM Hub Unand Figma design
/// (Light theme - Clean Campus White & Emerald Green).
class AppColors {
  AppColors._();

  // Backgrounds (Clean White / Off-white)
  static const Color background = Color(0xFFF8FAFC); // Canvas background
  static const Color backgroundWhite = Color(0xFFFFFFFF);
  static const Color surfaceCard = Color(0xFFFFFFFF);
  static const Color surfaceInput = Color(0xFFF1F5F9);
  static const Color surfaceFooter = Color(0xFFF8FAFC);
  static const Color surfaceBadge = Color(0xFFE8F5E9);

  // Borders
  static const Color borderSubtle = Color(0xFFE2E8F0);
  static const Color borderInput = Color(0xFFCBD5E1);

  // Brand Green (Emerald Unand)
  static const Color primaryGreenLight = Color(0xFF2E7D32);
  static const Color primaryGreenDark = Color(0xFF1B5E3C);
  static const Color accentGreen = Color(0xFF1B5E3C);
  static const Color primary = Color(0xFF1B5E3C);

  // Text
  static const Color textPrimary = Color(0xFF0F172A); // Deep slate / charcoal
  static const Color textSecondary = Color(0xFF475569); // Slate grey
  static const Color textLabel = Color(0xFF334155);
  static const Color textPlaceholder = Color(0xFF94A3B8);
  static const Color textOnButton = Color(0xFFFFFFFF);
  static const Color textFooter = Color(0xFF64748B);

  // Misc
  static const Color iconMuted = Color(0xFF64748B);
  static const Color accentGold = Color(0xFFD97706);
  static const Color error = Color(0xFFDC2626);

  // Gradients (Subtle white gradient / solid white feel)
  static const LinearGradient backgroundGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFFFFFFFF), Color(0xFFF8FAFC)],
  );

  static const LinearGradient primaryButtonGradient = LinearGradient(
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    colors: [Color(0xFF2E7D32), Color(0xFF1B5E3C)],
  );
}
