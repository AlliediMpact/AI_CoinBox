// File: lib/providers/user_provider.dart

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'membership_provider.dart'; // Import MembershipTier enum


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
  MembershipTier _membershipTier = MembershipTier.basic;
  double _commissionBalance = 0.0;
  double _securityDeposit = 0.0;


  /// Returns the currently authenticated user.
  User? get user => _user;

  /// Returns true if a user is logged in.
  bool get isLoggedIn => _user != null;

  /// Returns the user's profile data, including membership tier.

  Map<String, dynamic> get profileData => _profileData;

  /// Returns the user's full name.
  String get fullName => _profileData['fullName'] ?? '';

  /// Returns the user's email.
  String get email => _profileData['email'] ?? '';

  /// Returns the user's phone number.
  String get phone => _profileData['phone'] ?? '';

  /// Returns the user's profile image URL.
  String get profileImageUrl => _profileData['profileImageUrl'] ?? '';

  /// Returns the user's referral code.
  String get referralCode => _profileData['referralCode'] ?? '';

  /// Returns the user's commission balance, which is affected by the membership tier.

  double get commissionBalance => _commissionBalance;

  /// Returns the user's membership tier.
  MembershipTier get membershipTier => _membershipTier;

  /// Returns the user's security deposit.
  double get securityDeposit => _securityDeposit;


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

  /// Sets the user profile data and updates membership tier if necessary.

  /// 
  /// // WHY: This method stores additional user information fetched from Firestore.
  void setProfileData(Map<String, dynamic> data) {
    _profileData = data;
    notifyListeners();
  }

  /// Sets the total number of referrals and updates commission balance.

  void setTotalReferrals(int total) {
    _totalReferrals = total;
    notifyListeners();
  }

  /// Sets the list of top referrers and updates commission balance.

  void setTopReferrers(List<dynamic> referrers) {
    _topReferrers = referrers;
    notifyListeners();
  }

  /// Sets the user's membership tier.
  void setMembershipTier(MembershipTier tier) {
    _membershipTier = tier;
    notifyListeners();
  }

  /// Sets the user's commission balance.
  void setCommissionBalance(double balance) {
    _commissionBalance = balance;
    notifyListeners();
  }

  /// Sets the user's security deposit.
  void setSecurityDeposit(double deposit) {
    _securityDeposit = deposit;
    notifyListeners();
  }

  /// Adds commission to the user's balance.
  void addCommission(double amount) {
    _commissionBalance += amount;
    notifyListeners();
  }

}
