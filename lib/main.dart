import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'my_app.dart';
import 'firebase_options.dart'; // Import the generated file

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    runApp(const MyApp());
  } catch (e) {
    print('Firebase initialization error: $e');
    // Optionally, display an error message to the user
  }
}