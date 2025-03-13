// File: lib/screens/settings_screen.dart

import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../services/auth_service.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  Future<void> _logout(BuildContext context) async {
    try {
      await AuthService().signOut();
      Navigator.pushReplacementNamed(context, '/login');
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Logout failed: $error')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        backgroundColor: AppColors.primaryBlue,
      ),
      body: ListView(
        children: [
          ListTile(
            leading: const Icon(Icons.person),
            title: const Text('Account Details'),
            onTap: () {
              // Navigate to account details page
              Navigator.pushNamed(context, '/profile');
            },
          ),
          ListTile(
            leading: const Icon(Icons.security),
            title: const Text('Security Settings'),
            onTap: () {
              // Navigate to security settings page
            },
          ),
          ListTile(
            leading: const Icon(Icons.notifications),
            title: const Text('Notification Preferences'),
            onTap: () {
              // Navigate to notification settings page
            },
          ),
          ListTile(
            leading: const Icon(Icons.help),
            title: const Text('Help & Support'),
            onTap: () {
              // Navigate to FAQ or support page
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.logout),
            title: const Text('Logout'),
            onTap: () => _logout(context),
          ),
        ],
      ),
    );
  }
}
