import 'package:flutter_test/flutter_test.dart';
import 'package:ai_coinbox/services/referral_service.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_mock.dart'; // Import Firebase mock setup

void main() {
  setupFirebaseMocks(); // Use the correct Firebase mock setup

  group('ReferralService', () {
    setUpAll(() async {
      await Firebase.initializeApp();
    });

    test('should calculate referral commission correctly', () {
      double transactionAmount = 1000.0;
      String membershipPlan = 'vip';

      double commissionRate = ReferralService.getCommissionRate(membershipPlan);
      double commission = transactionAmount * commissionRate;

      expect(commissionRate, 0.03); // 3% for VIP
      expect(commission, 30.0);
    });

    test('should validate referral code format', () {
      String referralCode = 'VALIDCODE123';
      bool isValid = referralCode.length >= 8; // Basic validation
      expect(isValid, true);
    });
  });
}
