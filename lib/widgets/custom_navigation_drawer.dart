// File: lib/widgets/custom_navigation_drawer.dart

import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

class CustomNavigationDrawer extends StatelessWidget {
  const CustomNavigationDrawer({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Drawer(
      // Using zero padding to let our custom header span full width.
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          // Drawer header with branding.
          DrawerHeader(
            decoration: const BoxDecoration(
              color: AppColors.primaryBlue,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Display the logo (ensure this asset exists).
                Image.asset(
                  'assets/images/CoinBoxLogo02.png',
                  height: 60,
                ),
                const SizedBox(height: 8),
                const Text(
                  'Allied iMpact CoinBox',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          // Navigation menu items.
          ListTile(
            leading: const Icon(Icons.home, color: AppColors.primaryBlue),
            title: const Text('Home'),
            onTap: () {
              Navigator.pushNamed(context, '/home');
            },
          ),
          ListTile(
            leading: const Icon(Icons.info, color: AppColors.primaryBlue),
            title: const Text('About Us'),
            onTap: () {
              Navigator.pushNamed(context, '/about');
            },
          ),
          ListTile(
            leading: const Icon(Icons.contact_mail, color: AppColors.primaryBlue),
            title: const Text('Contact Us'),
            onTap: () {
              Navigator.pushNamed(context, '/contact');
            },
          ),
        ],
      ),
    );
  }
}
