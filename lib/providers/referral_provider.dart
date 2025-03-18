import 'package:flutter/material.dart';
import 'membership_provider.dart'; // Import MembershipTier enum

class ReferralProvider extends ChangeNotifier {
  final Map<String, double> _referrals = {};
  double _totalCommission = 0.0;

  Map<String, double> get referrals => _referrals;
  double get totalCommission => _totalCommission;

  void addReferral(String userId, double amount, MembershipTier tier) {
    double commissionRate = tier.commissionRate;
    double commission = amount * commissionRate;
    
    _referrals[userId] = (_referrals[userId] ?? 0) + commission;
    _totalCommission += commission;
    
    notifyListeners();
  }

  void resetCommission() {
    _totalCommission = 0.0;
    notifyListeners();
  }
}
