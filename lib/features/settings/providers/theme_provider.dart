import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:unigpa/domain/repositories/settings_repository.dart';

class ThemeProvider extends ChangeNotifier with WidgetsBindingObserver {
  ThemeProvider({required SettingsRepository repository})
      : _repository = repository {
    WidgetsBinding.instance.addObserver(this);
    _loadTheme();
  }

  final SettingsRepository _repository;

  ThemeMode _themeMode = ThemeMode.system;

  void _loadTheme() {
    final index = _repository.getThemeMode();
    _themeMode = ThemeMode.values[index];
    notifyListeners();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangePlatformBrightness() {
    if (_themeMode == ThemeMode.system) {
      notifyListeners();
    }
    super.didChangePlatformBrightness();
  }

  ThemeMode get themeMode => _themeMode;

  bool get isDark {
    if (_themeMode == ThemeMode.system) {
      return PlatformDispatcher.instance.platformBrightness == Brightness.dark;
    }
    return _themeMode == ThemeMode.dark;
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    if (_themeMode == mode) return;
    _themeMode = mode;
    notifyListeners();
    await _repository.setThemeMode(mode.index);
  }

  Future<void> toggleTheme() async {
    if (_themeMode == ThemeMode.system) {
      await setThemeMode(ThemeMode.light);
    } else if (_themeMode == ThemeMode.light) {
      await setThemeMode(ThemeMode.dark);
    } else {
      await setThemeMode(ThemeMode.system);
    }
  }
}
