import 'package:flutter_test/flutter_test.dart';
import 'package:ai_coinbox/providers/transaction_provider.dart';
import 'package:ai_coinbox/providers/transaction_provider.dart';


void main() {
  group('TransactionProvider', () {
    late TransactionProvider transactionProvider;

    setUp(() {
      transactionProvider = TransactionProvider();
    });

    test('should apply 25% repayment fee and 5% wallet allocation for loans', () {
      final loanTransaction = Transaction(
        id: 'txn1',
        userId: 'user1',
        amount: 1000.0,
        description: 'Loan request',
        type: TransactionType.loan,
        date: DateTime.now(),
        status: 'pending',
      );

      transactionProvider.addTransaction(loanTransaction);

      expect(loanTransaction.amount, 750.0); // 1000 - 250 (25% fee)
      expect(loanTransaction.description, 'Loan with repayment fee and wallet allocation');
    });
  });
}
