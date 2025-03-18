import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/user_provider.dart';
import 'providers/wallet_provider.dart';
import 'providers/transaction_provider.dart';
import 'providers/membership_provider.dart';


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
        ChangeNotifierProvider(create: (_) => MembershipProvider()),
      ],

      child: MaterialApp(
        title: 'Allied iMpact Coin Box',
        theme: ThemeData(
          primaryColor: AppColors.primaryBlue,
          colorScheme: ColorScheme.fromSwatch().copyWith(secondary: AppColors.primaryPurple),

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
          '/transaction_history': (context) => const TransactionHistoryScreen(), // Ensure this route is defined
          '/profile': (context) => const ProfileScreen(), 
          '/referrals': (context) => const ReferralsScreen(),
          '/settings': (context) => const SettingsScreen(),
          '/admin': (context) => const AdminDashboard(),
        },
      ),
    );
  }
}
