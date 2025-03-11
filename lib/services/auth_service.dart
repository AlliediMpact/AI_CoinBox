// File: lib/services/auth_service.dart

import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Other authentication methods...

  /// Deletes the currently signed-in user's account.
  Future<void> deleteAccount() async {
    User? user = _auth.currentUser;
    if (user != null) {
      await user.delete();
    } else {
      throw Exception("No user is currently signed in.");
    }
  }
}
