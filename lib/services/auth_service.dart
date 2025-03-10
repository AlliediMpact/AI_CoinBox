import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter/foundation.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  // Get current user
  User? get currentUser => _auth.currentUser;

  // Sign in with email and password
  Future<UserCredential> signInWithEmailAndPassword(
      String email, String password) async {
    try {
      final userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return userCredential;
    } on FirebaseAuthException catch (e) {
      // Handle specific Firebase Authentication exceptions
      switch (e.code) {
        case 'user-not-found':
          throw AuthException('No user found for that email.');
        case 'wrong-password':
          throw AuthException('Wrong password provided for that user.');
        case 'invalid-email':
          throw AuthException('The email is badly formatted.');
        default:
          throw AuthException('Sign in failed: ${e.message}');
      }
    } catch (e) {
      // Handle any other unexpected exceptions
      throw AuthException('Sign in failed: ${e.toString()}');
    }
  }

  // Sign up with email and password
  Future<UserCredential> signUpWithEmailAndPassword(
      String email, String password) async {
    try {
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      return userCredential;
    } on FirebaseAuthException catch (e) {
      // Handle specific Firebase Authentication exceptions
      switch (e.code) {
        case 'weak-password':
          throw AuthException('The password provided is too weak.');
        case 'email-already-in-use':
          throw AuthException('The account already exists for that email.');
        case 'invalid-email':
          throw AuthException('The email is badly formatted.');
        default:
          throw AuthException('Sign up failed: ${e.message}');
      }
    } catch (e) {
      // Handle any other unexpected exceptions
      throw AuthException('Sign up failed: ${e.toString()}');
    }
  }

  // Sign in with Google
  Future<UserCredential> signInWithGoogle() async {
    try {
      // Trigger the authentication flow
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      if (googleUser == null) {
        throw AuthException('Google Sign In was cancelled.');
      }
      // Obtain the auth details from request
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      // Create a new credential
      final OAuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Sign in with Firebase
      final userCredential = await _auth.signInWithCredential(credential);
      return userCredential;
    } on FirebaseAuthException catch (e) {
      throw AuthException('Google Sign in failed: ${e.message}');
    } catch (e) {
      throw AuthException('Google Sign in failed: ${e.toString()}');
    }
  }

  // Sign out
  Future<void> signOut() async {
    try {
      await _auth.signOut();
      await _googleSignIn.signOut(); // Sign out from Google as well
    } catch (e) {
      throw AuthException('Sign out failed: ${e.toString()}');
    }
  }

  // Send password reset email
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      // Handle specific Firebase Authentication exceptions
      switch (e.code) {
        case 'user-not-found':
          throw AuthException('No user found for that email.');
        case 'invalid-email':
          throw AuthException('The email is badly formatted.');
        default:
          throw AuthException('Failed to send password reset email: ${e.message}');
      }
    } catch (e) {
      // Handle any other unexpected exceptions
      throw AuthException('Failed to send password reset email: ${e.toString()}');
    }
  }
}

// Custom exception class for authentication errors
class AuthException implements Exception {
  final String message;
  AuthException(this.message);

  @override
  String toString() => 'AuthException: $message';
}
