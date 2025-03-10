import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';

// Screens
import '../screens/home_screen.dart';
import '../screens/auth/login_screen.dart';
import '../screens/loading_screen.dart';

// Providers
import '../providers/user_provider.dart';
import '../providers/wallet_provider.dart';
import '../providers/transaction_provider.dart';

class AuthenticationWrapper extends StatelessWidget {
  const AuthenticationWrapper({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        // Show loading screen while checking authentication state
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const LoadingScreen();
        }

        // User is authenticated
        if (snapshot.hasData) {
          // Initialize user data
          _initializeUserData(context, snapshot.data!.uid);
          return const HomeScreen();
        }

        // User is not authenticated
        return const LoginScreen();
      },
    );
  }

  // Method to initialize user-related data
  void _initializeUserData(BuildContext context, String userId) {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final walletProvider = Provider.of<WalletProvider>(context, listen: false);
    final transactionProvider = Provider.of<TransactionProvider>(context, listen: false);

    userProvider.update(userId);
    walletProvider.update(userId);
    transactionProvider.update(userId);
  }
}