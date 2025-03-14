// File: lib/widgets/header.dart

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import '../constants/app_colors.dart';
import '../providers/user_provider.dart';

class Header extends StatelessWidget implements PreferredSizeWidget {
  const Header({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    final bool isLoggedIn = userProvider.isLoggedIn;

    return AppBar(
      backgroundColor: Colors.white,
      elevation: 4,
      iconTheme: const IconThemeData(color: AppColors.primaryBlue),
      leading: IconButton(
        icon: const Icon(Icons.menu),
        onPressed: () {
          Scaffold.of(context).openDrawer();
        },
      ),
      title: InkWell(
        onTap: () {
          Navigator.pushNamed(context, '/home');
        },
        child: Row(
          children: [
            // Display the high-quality SVG logo.
            SvgPicture.asset(
              'assets/images/CoinBoxLogo01.svg',
              height: 40,
              semanticsLabel: 'CoinBox Logo',
            ),
            const SizedBox(width: 10),
            const Text(
              'Allied iMpact CoinBox',
              style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),
          ],
        ),
      ),
      actions: [
        // Search functionality.
        IconButton(
          icon: const Icon(Icons.search),
          onPressed: () {
            // TODO: Implement search functionality using SearchDelegate.
          },
        ),
        // Conditional rendering based on user authentication.
        isLoggedIn
            ? DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  icon: const Icon(Icons.account_circle, color: Colors.black),
                  items: [
                    DropdownMenuItem(
                      value: 'wallet',
                      child: Text('My Wallet (R${userProvider.profileData['walletBalance'] ?? 0})'),
                    ),
                    DropdownMenuItem(
                      value: 'commission',
                      child: Text('Commission (R${userProvider.commissionBalance.toStringAsFixed(2)})'),
                    ),
                    const DropdownMenuItem(
                      value: 'buy_coins',
                      child: Text('Buy Coins'),
                    ),
                    const DropdownMenuItem(
                      value: 'transactions',
                      child: Text('Transaction History'),
                    ),
                    const DropdownMenuItem(
                      value: 'settings',
                      child: Text('Settings'),
                    ),
                    const DropdownMenuItem(
                      value: 'logout',
                      child: Text('Logout'),
                    ),
                  ],
                  onChanged: (value) {
                    switch (value) {
                      case 'wallet':
                        Navigator.pushNamed(context, '/wallet');
                        break;
                      case 'commission':
                        Navigator.pushNamed(context, '/commission');
                        break;
                      case 'buy_coins':
                        Navigator.pushNamed(context, '/buy_coins');
                        break;
                      case 'transactions':
                        Navigator.pushNamed(context, '/transactions');
                        break;
                      case 'settings':
                        Navigator.pushNamed(context, '/settings');
                        break;
                      case 'logout':
                        // TODO: Implement proper logout functionality.
                        Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
                        break;
                    }
                  },
                ),
              )
            : Row(
                children: [
                  TextButton(
                    onPressed: () {
                      Navigator.pushNamed(context, '/signup');
                    },
                    child: const Text('Sign Up', style: TextStyle(color: AppColors.primaryBlue)),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.pushNamed(context, '/login');
                    },
                    child: const Text('Login', style: TextStyle(color: AppColors.primaryBlue)),
                  ),
                ],
              ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
