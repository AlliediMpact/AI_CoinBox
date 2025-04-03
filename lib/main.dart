import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'my_app.dart';
import 'firebase_options.dart'; // Import the generated file
import 'screens/kyc/kyc_screen.dart';
import 'screens/admin/kyc_management_screen.dart';
import 'services/auth_service.dart';
import 'screens/admin/admin_panel_screen.dart';
import 'screens/admin/system_reports_screen.dart';
import 'services/error_service.dart';
import 'dart:async'; // Add missing import for runZonedGuarded
import 'package:firebase_auth/firebase_auth.dart'; // Add missing import for FirebaseAuth
import 'screens/dashboard/dashboard_screen.dart'; // Ensure this import exists
import 'screens/auth/auth_screen.dart'; // Ensure this import exists

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    print('Firebase initialized successfully');
  } catch (e) {
    print('Error initializing Firebase: $e');
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AI CoinBox',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: FirebaseAuth.instance.currentUser != null
          ? const DashboardScreen()
          : const AuthScreen(),
      // Add debug print to confirm navigation
      builder: (context, child) {
        print('Navigating to: ${FirebaseAuth.instance.currentUser != null ? "DashboardScreen" : "AuthScreen"}');
        return child!;
      },
      routes: {
        '/kyc': (context) => KYCSubmissionScreen(
              userId: FirebaseAuth.instance.currentUser?.uid ?? '',
            ),
        '/admin/kyc-management': (context) => FutureBuilder<bool>(
              future: AuthService.isAdmin(FirebaseAuth.instance.currentUser!.uid),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Scaffold(
                    body: Center(child: CircularProgressIndicator()),
                  );
                }

                if (snapshot.hasError || !(snapshot.data ?? false)) {
                  return const Scaffold(
                    body: Center(
                      child: Text(
                        'Access Denied',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    ),
                  );
                }

                return const KYCManagementScreen();
              },
            ),
        '/admin/panel': (context) => FutureBuilder<bool>(
              future: AuthService.isAdmin(FirebaseAuth.instance.currentUser!.uid),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Scaffold(
                    body: Center(child: CircularProgressIndicator()),
                  );
                }

                if (snapshot.hasError || !(snapshot.data ?? false)) {
                  return const Scaffold(
                    body: Center(
                      child: Text(
                        'Access Denied',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    ),
                  );
                }

                return const AdminPanelScreen();
              },
            ),
        '/admin/reports': (context) => FutureBuilder<bool>(
              future: AuthService.isAdmin(FirebaseAuth.instance.currentUser!.uid),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Scaffold(
                    body: Center(child: CircularProgressIndicator()),
                  );
                }

                if (snapshot.hasError || !(snapshot.data ?? false)) {
                  return const Scaffold(
                    body: Center(
                      child: Text(
                        'Access Denied',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    ),
                  );
                }

                return const SystemReportsScreen();
              },
            ),
      },
    );
  }
}