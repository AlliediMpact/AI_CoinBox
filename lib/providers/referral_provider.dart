import 'package:flutter/material.dart';
import 'membership_provider.dart'; // Import MembershipTier enum
import 'package:cloud_firestore/cloud_firestore.dart';

class ReferralProvider extends ChangeNotifier {
  final Map<String, double> _referrals = {};
  double _totalCommission = 0.0;
  List<String> _topReferrers = []; // List to store top referrers

  Map<String, double> get referrals => _referrals;
  double get totalCommission => _totalCommission;
  List<String> get topReferrers => _topReferrers;

  void addReferral(String userId, double amount, MembershipTier tier) {
    double commissionRate = tier.commissionRate;
    double commission = amount * commissionRate;

    _referrals[userId] = (_referrals[userId] ?? 0) + commission;
    _totalCommission += commission;

    _updateTopReferrers(userId); // Update top referrers list

    notifyListeners();
  }

  void resetCommission() {
    _totalCommission = 0.0;
    notifyListeners();
  }

  // Method to update the list of top referrers
  void _updateTopReferrers(String userId) {
    // Sort referrals by commission earned
    List<MapEntry<String, double>> sortedReferrals = _referrals.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    // Get the top 3 referrers
    _topReferrers = sortedReferrals.take(3).map((entry) => entry.key).toList();

    notifyListeners();
  }

  // Method to award bonuses to top referrers
  Future<void> awardBonuses() async {
    // Implement logic to award bonuses to top referrers
    for (String userId in _topReferrers) {
      // Example: Award a bonus of 10% of their total commission
      double bonusAmount = _referrals[userId]! * 0.10;
      // Implement logic to transfer the bonus to the user's wallet
      try {
        await FirebaseFirestore.instance.collection('users').doc(userId).update({
          'walletBalance': FieldValue.increment(bonusAmount),
        });
        print('Awarded bonus of $bonusAmount to user $userId');
      } catch (e) {
        print('Error awarding bonus to user $userId: $e');
      }
    }
    notifyListeners();
  }
}
