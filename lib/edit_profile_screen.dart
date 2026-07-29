import 'package:flutter/material.dart';
import 'settings_screen.dart';

// Re-export SettingsScreen as EditProfileScreen for seamless compatibility
class EditProfileScreen extends StatelessWidget {
  const EditProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const SettingsScreen();
  }
}
