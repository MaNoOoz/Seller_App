import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

class ThemeService extends GetxService {
  final _box = GetStorage();
  final _key = 'isDarkMode'; // Key for storing theme preference

  /// Reads the stored theme mode. Returns true for dark, false for light, null for system.
  bool? _loadThemeFromBox() {
    // null means system theme, true means dark, false means light
    return _box.read(_key);
  }

  /// Saves the theme mode to storage.
  _saveThemeToBox(bool isDarkMode) => _box.write(_key, isDarkMode);

  /// Get the current theme mode (light, dark, or system).
  ThemeMode get themeMode {
    final bool? isDarkMode = _loadThemeFromBox();
    if (isDarkMode == null) {
      // If no preference is stored, use system theme
      return ThemeMode.system;
    } else {
      // Otherwise, use stored preference
      return isDarkMode ? ThemeMode.dark : ThemeMode.light;
    }
  }

  /// Toggles between light and dark theme.
  /// If currently system, it will switch to dark.
  void switchTheme() {
    if (Get.isDarkMode) {
      // Currently dark (or system in dark), switch to light
      Get.changeThemeMode(ThemeMode.light);
      _saveThemeToBox(false);
    } else {
      // Currently light (or system in light), switch to dark
      Get.changeThemeMode(ThemeMode.dark);
      _saveThemeToBox(true);
    }
  }

  /// Sets the theme explicitly to system default.
  void setSystemTheme() {
    Get.changeThemeMode(ThemeMode.system);
    _box.remove(_key); // Remove stored preference to default to system
  }
}