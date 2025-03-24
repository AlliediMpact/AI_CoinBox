import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

enum MembershipTier {
  basic,
  ambassador,
  vip,
  business
}

extension MembershipTierExtension on MembershipTier {
  String get name {
    switch (this) {
      case MembershipTier.basic:
        return 'Basic';
      case MembershipTier.ambassador:
        return 'Ambassador';
      case MembershipTier.vip:
        return 'VIP';
      case MembershipTier.business:
        return 'Business';
    }
  }

  double get securityFee {
    switch (this) {
      case MembershipTier.basic:
        return 500.0;
      case MembershipTier.ambassador:
        return 1000.0;
      case MembershipTier.vip:
        return 5000.0;
      case MembershipTier.business:
        return 10000.0;
    }
  }

  double get administrationFee {
    switch (this) {
      case MembershipTier.basic:
        return 50.0;
      case MembershipTier.ambassador:
        return 100.0;
      case MembershipTier.vip:
        return 500.0;
      case MembershipTier.business:
        return 1000.0;
    }
  }

  double get loanLimit {
    switch (this) {
      case MembershipTier.basic:
        return 500.0;
      case MembershipTier.ambassador:
        return 1000.0;
      case MembershipTier.vip:
        return 5000.0;
      case MembershipTier.business:
        return 10000.0;
    }
  }

  double get investmentLimit {
    switch (this) {
      case MembershipTier.basic:
        return 5000.0;
      case MembershipTier.ambassador:
        return 10000.0;
      case MembershipTier.vip:
        return 50000.0;
      case MembershipTier.business:
        return 100000.0;
    }
  }

  double get commissionRate {
    switch (this) {
      case MembershipTier.basic:
        return 0.01;
      case MembershipTier.ambassador:
        return 0.02;
      case MembershipTier.vip:
        return 0.03;
      case MembershipTier.business:
        return 0.05;
    }
  }
}

class MembershipProvider extends ChangeNotifier {
  MembershipTier _currentTier = MembershipTier.basic;
  double _securityDeposit = 0.0;
  double _availableBalance = 0.0;

  MembershipTier get currentTier => _currentTier;
  double get securityDeposit => _securityDeposit;
  double get availableBalance => _availableBalance;

  void upgradeMembership(MembershipTier newTier) {
    _currentTier = newTier;
    _securityDeposit = newTier.securityFee;
    notifyListeners();
  }

  void processTransaction(double amount) {
    _availableBalance += amount;
    notifyListeners();
  }

  bool canTakeLoan(double amount) {
    return amount <= _currentTier.loanLimit;
  }

  bool canMakeInvestment(double amount) {
    return amount <= _currentTier.investmentLimit;
  }

  // Method to calculate refundable amount upon membership exit
  double calculateRefundableAmount() {
    // Implement logic to calculate refundable amount based on membership tier and duration
    // This is a placeholder
    switch (_currentTier) {
      case MembershipTier.basic:
        return _securityDeposit * 0.5; // Example: 50% refund
      case MembershipTier.ambassador:
        return _securityDeposit * 0.75; // Example: 75% refund
      case MembershipTier.vip:
        return _securityDeposit * 0.9; // Example: 90% refund
      case MembershipTier.business:
        return _securityDeposit; // Example: Full refund
    }
  }

  // Method to process membership exit and refund
  Future<void> processMembershipExit(String userId) async {
    double refundableAmount = calculateRefundableAmount();
    try {
      // Transfer refundable amount to user's wallet
      await FirebaseFirestore.instance.collection('users').doc(userId).update({
        'walletBalance': FieldValue.increment(refundableAmount),
      });

      // Reset membership tier and security deposit
      _currentTier = MembershipTier.basic;
      _securityDeposit = 0.0;
      notifyListeners();
    } catch (e) {
      print('Error processing membership exit: $e');
      throw Exception('Failed to process membership exit.');
    }
  }

  Future<void> updateWalletBalance(String userId, double refundableAmount) async {
    try {
      await FirebaseFirestore.instance.collection('users').doc(userId).update({
        'walletBalance': FieldValue.increment(refundableAmount),
      });
    } catch (e) {
      throw Exception('Error updating wallet balance: $e');
    }
  }
}
