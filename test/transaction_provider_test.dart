import 'package:flutter_test/flutter_test.dart';
import 'package:ai_coinbox/providers/transaction_provider.dart';
import 'package:ai_coinbox/providers/membership_provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_mock.dart'; // Import Firebase mock setup

void main() {
  setupFirebaseMocks(); // Use the correct Firebase mock setup

  group('TransactionProvider', () {
    late TransactionProvider transactionProvider;

    setUpAll(() async {
      await Firebase.initializeApp();
    });

    setUp(() {
      transactionProvider = TransactionProvider();
    });

    test('should calculate loan repayment correctly', () async {
      final loanTransaction = Transaction(
        id: 'txn1',
        userId: 'user1',
        amount: 1000.0,
        description: 'Loan request',
        type: TransactionType.loan, // Correctly reference TransactionType
        date: DateTime.now(),
        status: 'pending',
      );

      await transactionProvider.processLoanRepayment(loanTransaction);

      double repaymentFee = loanTransaction.amount * 0.25;
      double walletAllocation = repaymentFee * 0.05;
      double investorAmount = repaymentFee - walletAllocation;

      expect(walletAllocation, 12.5);
      expect(investorAmount, 237.5);
    });

    test('should enforce membership-specific loan limits', () {
      transactionProvider.setMembershipTier(MembershipTier.basic);

      expect(() => transactionProvider.addTransaction(Transaction(
            id: 'txn2',
            userId: 'user1',
            amount: 600.0,
            description: 'Loan request exceeding limit',
            type: TransactionType.loan, // Correctly reference TransactionType
            date: DateTime.now(),
            status: 'pending',
          )), throwsException);
    });
  });
}
