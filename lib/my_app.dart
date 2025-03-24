import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/user_provider.dart';
import 'providers/wallet_provider.dart';
import 'providers/transaction_provider.dart';
import 'providers/membership_provider.dart';
import 'utils/app_colors.dart'; // Import AppColors
import 'screens/auth/auth_screen.dart'; // Import AuthScreen
import 'screens/home_screen.dart'; // Import HomeScreen
import 'screens/wallet_screen.dart'; // Import WalletScreen
import 'screens/trade_screen.dart'; // Import TradeScreen
import 'screens/transaction_history_screen.dart'; // Import TransactionHistoryScreen
import 'screens/profile_screen.dart'; // Import ProfileScreen
import 'screens/referrals_screen.dart'; // Import ReferralsScreen
import 'screens/settings_screen.dart'; // Import SettingsScreen
import 'screens/onboarding_screen.dart'; // Import OnboardingScreen
import 'screens/splash_screen.dart'; // Import SplashScreen
import 'screens/paystack_test_screen.dart'; // Import the test screen

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

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
        initialRoute: '/splash', // Ensure this matches a valid route
        routes: {
          '/splash': (context) => const SplashScreen(),
          '/auth': (context) => const AuthScreen(),
          '/home': (context) => const HomeScreen(),
          '/wallet': (context) => const WalletScreen(),
          '/trade': (context) => const TradeScreen(),
          '/transaction_history': (context) => const TransactionHistoryScreen(),
          '/profile': (context) => const ProfileScreen(),
          '/referrals': (context) => const ReferralsScreen(),
          '/onboarding': (context) => const OnboardingScreen(),
          '/settings': (context) => const SettingsScreen(),
          '/paystack_test': (context) => const PaystackTestScreen(),
        },
        onUnknownRoute: (settings) {
          return MaterialPageRoute(
            builder: (context) => Scaffold(
              body: Center(
                child: Text('Unknown route: ${settings.name}'),
              ),
            ),
          );
        },
      ),
    );
  }
}