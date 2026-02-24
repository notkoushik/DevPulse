import 'package:flutter/material.dart';
import 'app_theme.dart';

class ThemeProvider extends ChangeNotifier {
  bool _isDark = true;

  bool get isDark => _isDark;
  DevPulseTheme get dpTheme => _isDark ? DevPulseTheme.dark : DevPulseTheme.light;
  ThemeData get themeData => DevPulseTheme.materialTheme(_isDark);

  void toggleTheme() {
    _isDark = !_isDark;
    notifyListeners();
  }
}
