import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';

// Providers
import '../providers/user_provider.dart';
import '../providers/wallet_provider.dart';
import '../providers/transaction_provider.dart';
import '../providers/theme_provider.dart';

// Screens
import '../screens/home_screen.dart';
import '../screens/profile_screen.dart';
import '../screens/wallet_screen.dart';
import '../screens/trade_screen.dart';
import '../screens/referrals_screen.dart';
import '../screens/about_us_screen.dart';
import '../screens/contact_us_screen.dart';
import '../screens/settings_screen.dart';
import '../screens/auth/login_screen.dart';

// Widgets
import 'authentication_wrapper.dart';

// Services
import '../services/notification_service.dart';
import '../services/security_service.dart';
import '../middleware/security_middleware.dart';

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initializeServices();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      // App came to the foreground
      _checkSecurity();
    } else if (state == AppLifecycleState.paused) {
      // App went to the background
      SecurityService.updateLastActivity();
    }
  }

  Future<void> _initializeServices() async {
    // Initialize notification service
    await NotificationService.initialize();
  }

  Future<void> _checkSecurity() async {
    final context = navigatorKey.currentContext;
    if (context == null) return;

    // Check if user is authenticated
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    // Check if session has timed out
    final hasTimedOut = await SecurityMiddleware.checkSessionTimeout(context);
    if (hasTimedOut) return;

    // Check if biometric authentication is required
    final biometricPassed = await SecurityMiddleware.checkBiometricAuth(context);
    if (!biometricPassed) return;

    // Check if PIN authentication is required
    await SecurityMiddleware.checkPinAuth(context);
  }

  static final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // User provider
        ChangeNotifierProvider(
          create: (_) => UserProvider(),
        ),
        // Wallet provider
        ChangeNotifierProvider(
          create: (_) => WalletProvider(),
        ),
        // Transaction provider
        ChangeNotifierProvider(
          create: (_) => TransactionProvider(),
        ),
        // Theme provider
        ChangeNotifierProvider(
          create: (_) => ThemeProvider(),
        ),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, child) {
          return MaterialApp(
            title: 'AI CoinBox',
            theme: themeProvider.getTheme(),
            debugShowCheckedModeBanner: false,
            navigatorKey: navigatorKey,
            home: const AuthenticationWrapper(),
            routes: {
              '/home': (context) => const HomeScreen(),
              '/profile': (context) => const ProfileScreen(),
              '/wallet': (context) => const WalletScreen(),
              '/trade': (context) => const TradeScreen(),
              '/referrals': (context) => const ReferralsScreen(),
              '/about': (context) => const AboutUsScreen(),
              '/contact': (context) => const ContactUsScreen(),
              '/settings': (context) => const SettingsScreen(),
              '/login': (context) => const LoginScreen(),
            },
          );
        },
      ),
    );
  }
}