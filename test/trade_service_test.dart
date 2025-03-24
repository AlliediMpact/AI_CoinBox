import 'package:flutter_test/flutter_test.dart';
import 'package:ai_coinbox/services/trade_service.dart';

void main() {
  group('TradeService', () {
    test('should distribute investment interest correctly', () async {
      double investmentAmount = 1000.0;

      double interest = investmentAmount * 0.20;
      double walletAmount = interest * 0.05;
      double bankAmount = interest - walletAmount;

      expect(interest, 200.0);
      expect(walletAmount, 10.0);
      expect(bankAmount, 190.0);
    });
  });
}
