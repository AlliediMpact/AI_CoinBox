import 'package:flutter/material.dart';

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
}
