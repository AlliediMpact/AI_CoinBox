import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'my_app.dart'; // Make sure this file exists in the lib/ directory

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}
