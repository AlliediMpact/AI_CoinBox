// File: lib/services/auth_service.dart

import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:math';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Signs out the currently signed-in user.
  Future<void> signOut() async {
    await _auth.signOut();
  }

  /// Deletes the currently signed-in user's account.
  Future<void> deleteAccount() async {
    User? user = _auth.currentUser;
    if (user != null) {
      await user.delete();
    } else {
      throw Exception("No user is currently signed in.");
    }
  }

  /// Resets the password for the given email and sends an OTP for verification.

  Future<void> resetPassword(String email) async {
    await _auth.sendPasswordResetEmail(email: email);
  }

  /// Prevent suspended users from logging in.
  Future<void> checkUserSuspension(String userId) async {
    final userDoc = await _firestore.collection('users').doc(userId).get();
    if (userDoc.exists && userDoc.data()?['isSuspended'] == true) {
      throw Exception('Your account is suspended. Please contact support.');
    }
  }

  // Check if the current user is an admin
  static Future<bool> isAdmin(String userId) async {
    final userDoc = await _firestore.collection('users').doc(userId).get();
    if (!userDoc.exists) return false;

    final data = userDoc.data();
    return data?['role'] == 'admin';
  }

  /// Set security questions for account recovery
  static Future<void> setSecurityQuestions(String userId, Map<String, String> questions) async {
    await _firestore.collection('users').doc(userId).update({
      'securityQuestions': questions,
    });
  }

  /// Verify answers to security questions
  static Future<bool> verifySecurityQuestions(String userId, Map<String, String> answers) async {
    final userDoc = await _firestore.collection('users').doc(userId).get();
    final storedQuestions = userDoc.data()?['securityQuestions'] as Map<String, dynamic>?;

    if (storedQuestions == null) return false;

    for (final question in answers.keys) {
      if (storedQuestions[question] != answers[question]) {
        return false;
      }
    }
    return true;
  }

  /// Generate OTP and send it to the user's email for verification.

  static Future<void> sendOTP(String email) async {
    final otp = _generateOTP();
    _otpStorage[email] = otp;

    // Simulate sending OTP via email (replace with actual email service)
    print('OTP for $email: $otp');
  }

  /// Verify the OTP entered by the user and return true if it matches.

  static Future<bool> verifyOTP(String email, String enteredOTP) async {
    final storedOTP = _otpStorage[email];
    if (storedOTP == null || storedOTP != enteredOTP) {
      return false;
    }

    // Clear OTP after successful verification
    _otpStorage.remove(email);
    return true;
  }

  /// Generate a 6-digit OTP
  static String _generateOTP() {
    final random = Random();
    return (random.nextInt(900000) + 100000).toString(); // 6-digit OTP
  }

  // Temporary OTP storage
  static final Map<String, String> _otpStorage = {};

  static Map<String, String> get otpStorage => _otpStorage;
}
