import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'dart:io';
import 'theme_provider.dart';

ImageProvider? getAvatarImageProvider(String? path) {
  if (path == null || path.isEmpty) return null;
  try {
    if (kIsWeb) {
      if (path.startsWith('blob:') || path.startsWith('http')) {
        return NetworkImage(path);
      }
      return null;
    } else {
      final file = File(path);
      if (file.existsSync()) {
        return FileImage(file);
      }
    }
  } catch (_) {}
  return null;
}

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  Widget _colorSwatch(
      BuildContext context, String code, String label, Color color) {
    final themeProvider = AppThemeProvider.of(context);
    final isSelected = themeProvider.accentName == code;

    return GestureDetector(
      onTap: () => themeProvider.setAccentColor(code),
      child: Column(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
              border: isSelected
                  ? Border.all(color: Colors.white, width: 3)
                  : null,
              boxShadow: [
                BoxShadow(
                    color: color.withOpacity(0.4),
                    blurRadius: isSelected ? 10 : 4)
              ],
            ),
            child: isSelected
                ? const Icon(Icons.check, color: Colors.white, size: 22)
                : null,
          ),
          const SizedBox(height: 6),
          Text(label,
              style: TextStyle(
                  fontSize: 11,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  color: isSelected ? color : Colors.grey)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = AppThemeProvider.of(context);
    final primaryColor = themeProvider.primaryColor;
    final isDark = themeProvider.isDarkMode;

    return Scaffold(
      backgroundColor:
          isDark ? const Color(0xFF121212) : const Color(0xFFF5F7FF),
      appBar: AppBar(
        title: const Text('Settings',
            style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Dark Mode Toggle
            Container(
              padding: const EdgeInsets.all(18),
              margin: const EdgeInsets.only(bottom: 20),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 8,
                      offset: const Offset(0, 2)),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(Icons.dark_mode_rounded,
                          color: primaryColor, size: 22),
                      const SizedBox(width: 12),
                      Text('Dark Mode',
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                              color: isDark
                                  ? Colors.white
                                  : const Color(0xFF1A1A2E))),
                    ],
                  ),
                  Switch(
                    value: themeProvider.isDarkMode,
                    activeColor: primaryColor,
                    onChanged: (val) => themeProvider.setDarkMode(val),
                  ),
                ],
              ),
            ),

            // 2. Accent Color Picker
            Container(
              padding: const EdgeInsets.all(18),
              margin: const EdgeInsets.only(bottom: 20),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 8,
                      offset: const Offset(0, 2)),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Theme Accent Color',
                      style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: isDark
                              ? Colors.white
                              : const Color(0xFF1A1A2E))),
                  const SizedBox(height: 14),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _colorSwatch(context, 'blue', 'Ocean Blue',
                          const Color(0xFF1A73E8)),
                      _colorSwatch(context, 'orange', 'Sunset Orange',
                          const Color(0xFFC84B31)),
                      _colorSwatch(context, 'green', 'Forest Green',
                          const Color(0xFF1B5E20)),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
