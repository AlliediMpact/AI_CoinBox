// File: lib/my_app.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'constants/app_colors.dart';
import 'screens/auth/auth_screen.dart'; // Your consolidated authentication screen
import 'screens/home_screen.dart';
import 'screens/wallet_screen.dart';
import 'screens/trade_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/referrals_screen.dart';
import 'screens/settings_screen.dart';
import 'screens/admin/admin_dashboard.dart';
import 'providers/user_provider.dart';
import 'providers/wallet_provider.dart';
import 'providers/transaction_provider.dart';

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // Build overall app theme and routing
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => UserProvider()),
        ChangeNotifierProvider(create: (_) => WalletProvider()),
        ChangeNotifierProvider(create: (_) => TransactionProvider()),
      ],
      child: MaterialApp(
        title: 'Allied iMpact Coin Box',
        theme: ThemeData(
          primaryColor: AppColors.primaryBlue,
          accentColor: AppColors.primaryPurple,
          appBarTheme: const AppBarTheme(
            backgroundColor: AppColors.primaryBlue,
            iconTheme: IconThemeData(color: Colors.white),
          ),
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryBlue,
              padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
              textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
          fontFamily: 'Roboto',
        ),
        initialRoute: '/',
        routes: {
          '/': (context) => const AuthScreen(), // Start with authentication
          '/home': (context) => const HomeScreen(),
          '/wallet': (context) => const WalletScreen(),
          '/trade': (context) => const TradeScreen(),
          '/profile': (context) => const ProfileScreen(),
          '/referrals': (context) => const ReferralsScreen(),
          '/settings': (context) => const SettingsScreen(),
          '/admin': (context) => const AdminDashboard(),
        },
      ),
    );
  }
}
