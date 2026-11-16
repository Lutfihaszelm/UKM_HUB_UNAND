import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../services/storage_service.dart';

/// A [Notifier] that holds the current [ThemeMode] (light or dark).
///
/// It reads the persisted preference from [StorageService] when built and
/// updates the stored value whenever the user toggles the theme.
class ThemeNotifier extends Notifier<ThemeMode> {
  @override
  ThemeMode build() {
    // Load persisted setting; default to light if not set.
    final isDark = StorageService.instance.isDarkMode;
    return isDark ? ThemeMode.dark : ThemeMode.light;
  }

  /// Toggle between light and dark mode and persist the choice.
  void toggleTheme() {
    state = state == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
    StorageService.instance.setDarkMode(state == ThemeMode.dark);
  }
}

/// Riverpod provider exposing the current [ThemeMode] and the ability to toggle.
final themeNotifierProvider =
    NotifierProvider<ThemeNotifier, ThemeMode>(ThemeNotifier.new);
