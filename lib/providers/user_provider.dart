// File: lib/providers/user_provider.dart

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

/// UserProvider manages user authentication state and profile data.
///
/// WHY: This provider stores the currently authenticated Firebase user,
/// profile data loaded from Firestore, referral stats, and provides convenient
/// getters for UI components (e.g., isLoggedIn, profileData).
class UserProvider extends ChangeNotifier {
  User? _user;
  Map<String, dynamic> _profileData = {};
  int _totalReferrals = 0;
  List<dynamic> _topReferrers = [];

  /// Returns the currently authenticated user.
  User? get user => _user;

  /// Returns true if a user is logged in.
  bool get isLoggedIn => _user != null;

  /// Returns the user's profile data.
  Map<String, dynamic> get profileData => _profileData;

  /// Returns the total number of referrals.
  int get totalReferrals => _totalReferrals;

  /// Returns a list of top referrers.
  List<dynamic> get topReferrers => _topReferrers;

  /// Sets the current Firebase user.
  /// 
  /// // WHY: Updating the user ensures that UI components depending on
  /// authentication state update automatically.
  void setUser(User? newUser) {
    _user = newUser;
    notifyListeners();
  }

  /// Sets the user profile data.
  /// 
  /// // WHY: This method stores additional user information fetched from Firestore.
  void setProfileData(Map<String, dynamic> data) {
    _profileData = data;
    notifyListeners();
  }

  /// Sets the total number of referrals.
  void setTotalReferrals(int total) {
    _totalReferrals = total;
    notifyListeners();
  }

  /// Sets the list of top referrers.
  void setTopReferrers(List<dynamic> referrers) {
    _topReferrers = referrers;
    notifyListeners();
  }
}
