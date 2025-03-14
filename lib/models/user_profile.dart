// File: lib/models/user_profile.dart

import 'package:cloud_firestore/cloud_firestore.dart';

/// A model class representing a user's profile.
class UserProfile {
  final String uid;
  final String email;
  final String membershipTier;
  int loanLimit;
  int investmentLimit;

  /// Constructor for [UserProfile].
  UserProfile({
    required this.uid,
    required this.email,
    required this.membershipTier,
    required this.loanLimit,
    required this.investmentLimit,
  });

  /// Factory method to create a [UserProfile] from a Firestore document.
  factory UserProfile.fromMap(String uid, Map<String, dynamic> data) {
    int loanLimit;
    int investmentLimit;

    // Determine limits based on membership tier.
    switch ((data['membershipTier'] as String).toLowerCase()) {
      case 'basic':
        loanLimit = 500;
        investmentLimit = 5000;
        break;
      case 'ambassador':
        loanLimit = 1000;
        investmentLimit = 10000;
        break;
      case 'vip':
        loanLimit = 5000;
        investmentLimit = 50000;
        break;
      case 'business':
        loanLimit = 10000;
        investmentLimit = 100000;
        break;
      default:
        // Default limits if membershipTier is not recognized.
        loanLimit = 500;
        investmentLimit = 5000;
        break;
    }

    return UserProfile(
      uid: uid,
      email: data['email'] ?? '',
      membershipTier: data['membershipTier'] ?? 'basic',
      loanLimit: loanLimit,
      investmentLimit: investmentLimit,
    );
  }

  /// Converts the [UserProfile] instance into a Map for Firestore storage.
  Map<String, dynamic> toMap() {
    return {
      'email': email,
      'membershipTier': membershipTier,
      'loanLimit': loanLimit,
      'investmentLimit': investmentLimit,
    };
  }

  /// Static method to create a new user profile in Firestore.
  /// 
  /// **WHY:** This method ensures that every new user has a corresponding
  /// profile document in the 'users' collection.
  static Future<void> create(String uid, Map<String, dynamic> data) async {
    await FirebaseFirestore.instance.collection('users').doc(uid).set(data);
  }

  /// Static method to update the user profile in Firestore.
  /// 
  /// **WHY:** This allows updating the profile without fetching the entire document.
  static Future<void> update(String uid, Map<String, dynamic> data) async {
    await FirebaseFirestore.instance.collection('users').doc(uid).update(data);
  }
}
