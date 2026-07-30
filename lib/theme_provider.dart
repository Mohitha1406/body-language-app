import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeProvider extends ChangeNotifier {
  bool _isDarkMode = false;
  String _accentName = 'blue'; // 'blue', 'orange', 'green'

  bool get isDarkMode => _isDarkMode;
  String get accentName => _accentName;

  Color get primaryColor {
    switch (_accentName) {
      case 'orange':
        return const Color(0xFFC84B31); // Muted Terracotta / Sunset Orange
      case 'green':
        return const Color(0xFF1B5E20); // Deep Forest Emerald Green
      case 'blue':
      default:
        return const Color(0xFF1A73E8); // Ocean Blue
    }
  }

  String get accentDisplayName {
    switch (_accentName) {
      case 'orange':
        return 'Sunset Orange';
      case 'green':
        return 'Forest Green';
      case 'blue':
      default:
        return 'Ocean Blue';
    }
  }

  static Future<ThemeProvider> create() async {
    final provider = ThemeProvider();
    await provider.loadFromPrefs();
    return provider;
  }

  Future<void> loadFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    _isDarkMode = prefs.getBool('is_dark_mode') ?? false;
    _accentName = prefs.getString('accent_color') ?? 'blue';
    notifyListeners();
  }

  Future<void> setDarkMode(bool value) async {
    if (_isDarkMode == value) return;
    _isDarkMode = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('is_dark_mode', value);
    notifyListeners();
  }

  Future<void> setAccentColor(String name) async {
    if (_accentName == name) return;
    _accentName = name;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('accent_color', name);
    notifyListeners();
  }

  ThemeData get themeData {
    final baseScheme = ColorScheme.fromSeed(
      seedColor: primaryColor,
      brightness: _isDarkMode ? Brightness.dark : Brightness.light,
    );

    return ThemeData(
      colorScheme: baseScheme.copyWith(
        primary: primaryColor,
        secondary: primaryColor,
      ),
      useMaterial3: true,
      brightness: _isDarkMode ? Brightness.dark : Brightness.light,
      scaffoldBackgroundColor:
          _isDarkMode ? const Color(0xFF121212) : const Color(0xFFF5F7FF),
      appBarTheme: AppBarTheme(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
        ),
      ),
      cardColor: _isDarkMode ? const Color(0xFF1E1E1E) : Colors.white,
    );
  }
}

class AppThemeProvider extends InheritedNotifier<ThemeProvider> {
  const AppThemeProvider({
    super.key,
    required ThemeProvider themeProvider,
    required super.child,
  }) : super(notifier: themeProvider);

  static ThemeProvider of(BuildContext context) {
    final provider =
        context.dependOnInheritedWidgetOfExactType<AppThemeProvider>()?.notifier;
    return provider ?? ThemeProvider();
  }
}
