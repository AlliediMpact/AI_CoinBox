// File: lib/widgets/header.dart

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import '../providers/user_provider.dart';
import '../constants/app_colors.dart';

class Header extends StatelessWidget with PreferredSizeWidget {
  const Header({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    // Example: Determine authentication state (userProvider.isLoggedIn)
    bool isLoggedIn = userProvider.isLoggedIn;

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
          // Navigate to home page
          Navigator.pushNamed(context, '/home');
        },
        child: Row(
          children: [
            // Use high-quality PNG or SVG for logo
            SvgPicture.asset(
              'assets/images/CoinBoxLogo01.svg',
              height: 40,
              // You can add semanticsLabel for accessibility:
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
        // Search Icon with integrated SearchDelegate for dynamic search suggestions.
        IconButton(
          icon: const Icon(Icons.search),
          onPressed: () {
            showSearch(
              context: context,
              delegate: CustomSearchDelegate(), // Define CustomSearchDelegate separately.
            );
          },
        ),
        // Conditional account display
        isLoggedIn
            ? _buildAccountDropdown(context, userProvider)
            : Row(
                children: [
                  TextButton(
                    onPressed: () {
                      Navigator.pushNamed(context, '/signup');
                    },
                    child: const Text(
                      'Sign Up',
                      style: TextStyle(color: AppColors.primaryBlue),
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.pushNamed(context, '/login');
                    },
                    child: const Text(
                      'Login',
                      style: TextStyle(color: AppColors.primaryBlue),
                    ),
                  ),
                ],
              ),
      ],
    );
  }

  Widget _buildAccountDropdown(BuildContext context, var userProvider) {
    return DropdownButtonHideUnderline(
      child: DropdownButton<String>(
        icon: const Icon(Icons.account_circle, color: Colors.black),
        items: [
          DropdownMenuItem(
            value: 'wallet',
            child: Text('My Wallet (R${userProvider.walletBalance.toStringAsFixed(2)})'),
          ),
          DropdownMenuItem(
            value: 'commission',
            child: Text('Commission (R${userProvider.commissionBalance.toStringAsFixed(2)})'),
          ),
          DropdownMenuItem(
            value: 'buy_coins',
            child: const Text('Buy Coins'),
          ),
          DropdownMenuItem(
            value: 'transactions',
            child: const Text('Transaction History'),
          ),
          DropdownMenuItem(
            value: 'settings',
            child: const Text('Settings'),
          ),
          DropdownMenuItem(
            value: 'logout',
            child: const Text('Logout'),
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
              // Implement logout functionality here
              // Example: Provider.of<AuthService>(context, listen: false).signOut();
              Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
              break;
          }
        },
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

/// CustomSearchDelegate: Implements dynamic search suggestions.
class CustomSearchDelegate extends SearchDelegate {
  @override
  List<Widget>? buildActions(BuildContext context) {
    return [
      IconButton(
        icon: const Icon(Icons.clear),
        onPressed: () {
          query = '';
        },
      ),
    ];
  }

  @override
  Widget? buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () {
        close(context, null);
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    // Implement result display
    return Center(child: Text('Search results for "$query"'));
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    // Implement suggestions; for now, we show a simple list
    final suggestions = query.isEmpty
        ? ['Invest', 'Borrow', 'Wallet', 'Transactions']
        : ['Invest', 'Borrow', 'Wallet', 'Transactions']
            .where((s) => s.toLowerCase().contains(query.toLowerCase()))
            .toList();

    return ListView.builder(
      itemCount: suggestions.length,
      itemBuilder: (context, index) {
        return ListTile(
          title: Text(suggestions[index]),
          onTap: () {
            query = suggestions[index];
            showResults(context);
          },
        );
      },
    );
  }
}
