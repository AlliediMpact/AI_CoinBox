import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../config/firebase_config.dart';
import 'dart:async';
import 'auth_service.dart';

class FirebaseService {
  static final _initializedController = StreamController<bool>.broadcast();
  static Stream<bool> get isInitialized => _initializedController.stream;
  static final AuthService authService = AuthService();

  static Future<void> initializeFirebase() async {
    try {
      await Firebase.initializeApp(
        options: FirebaseConfig.platformOptions,
      );
      print('Firebase initialized successfully');
      _initializedController.add(true);
    } catch (e) {
      print('Error initializing Firebase: $e');
      _initializedController.addError(e);
    }
  }

  static dispose() {
    _initializedController.close();
  }

  static FirebaseFirestore get firestore => FirebaseFirestore.instance;
  static FirebaseAuth get auth => FirebaseAuth.instance;
}
