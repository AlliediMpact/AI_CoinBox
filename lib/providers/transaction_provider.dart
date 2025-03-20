import 'package:flutter/material.dart';
import 'membership_provider.dart'; // Import MembershipTier enum
import 'kyc_provider.dart'; // Import KYCProvider class
import 'escrow.dart'; // Import Escrow class
import 'package:cloud_firestore/cloud_firestore.dart';

// Define transaction types as an enum for type safety
enum TransactionType {
  deposit,
  withdrawal,
  investment,
  loan,
  commission,
  transfer,
  fee
}

// Extension to add string conversion methods to the enum
extension TransactionTypeExtension on TransactionType {
  String toShortString() {
    return toString().split('.').last;
  }
  
  String toUpperCase() {
    return toString().split('.').last.toUpperCase();
  }
  
  static TransactionType fromString(String value) {
    return TransactionType.values.firstWhere(
      (type) => type.toShortString() == value,
      orElse: () => TransactionType.fee,
    );
  }
}

/// A model representing a single transaction.
class Transaction {
  final String id;
  final String userId;
  double amount;
  String description;

  final TransactionType type; // e.g., 'investment', 'loan', 'commission'
  final DateTime date;
  final String status;
  final String? paymentMethod;
  final String? externalTransactionId;
  final String? recipientId;
  final String? senderId;

  Transaction({
    required this.id,
    required this.userId,
    required this.amount,
    required this.description,
    required this.type,
    required this.date,
    required this.status,
    this.paymentMethod,
    this.externalTransactionId,
    this.recipientId,
    this.senderId,
  });
}

class TransactionProvider extends ChangeNotifier {
  // List to hold transactions.
  List<Transaction> _transactions = [];

  // Getter to access the list of transactions.
  List<Transaction> get transactions => _transactions;

  MembershipTier _membershipTier = MembershipTier.basic; // Define membership tier
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Fetches transactions from the backend and handles loan requests.
  /// Currently, this method simulates data fetching with dummy data and includes loan management.

  Future<void> loadTransactions() async {
    await Future.delayed(const Duration(seconds: 1)); // Simulate network delay

    // Dummy data for demonstration purposes, including loan transactions.

    _transactions = [
      Transaction(
        // Loan transaction example
        id: 'txn4',
        userId: 'user1',
        amount: 500.0,
        description: 'Loan taken',
        date: DateTime.now().subtract(const Duration(days: 4)),
        type: TransactionType.loan,
        status: 'completed',
      ),
      Transaction(
        id: 'txn5',
        userId: 'user1',
        amount: 1000.0,
        description: 'Investment in real estate',
        date: DateTime.now().subtract(const Duration(days: 2)),
        type: TransactionType.investment,
        status: 'completed',
      ),
      Transaction(
        id: 'txn6',
        userId: 'user1',
        amount: 150.0,
        description: 'Investment in bonds',
        date: DateTime.now().subtract(const Duration(days: 1)),
        type: TransactionType.investment,
        status: 'completed',
      ),
      Transaction(
        id: 'txn7',
        userId: 'user1',
        amount: 100.0,
        description: 'Investment in stocks',
        date: DateTime.now().subtract(const Duration(days: 1)),
        type: TransactionType.investment,
        status: 'completed',
      ),
      Transaction(
        id: 'txn8',
        userId: 'user1',
        amount: 50.0,
        description: 'Loan repayment',
        date: DateTime.now().subtract(const Duration(days: 2)),
        type: TransactionType.loan,
        status: 'completed',
      ),
      Transaction(
        id: 'txn9',
        userId: 'user1',
        amount: 20.0,
        description: 'Commission earned',
        date: DateTime.now().subtract(const Duration(days: 3)),
        type: TransactionType.commission,
        status: 'completed',
      ),
    ];

    // Notify listeners about the updated data.
    notifyListeners();
  }

  /// Adds a new transaction or loan request to the list and notifies listeners.
  void addTransaction(Transaction transaction) async {
    if (transaction.type == TransactionType.loan) {
      if (!canTakeLoan(transaction.amount)) {
        throw Exception('Loan amount exceeds limit for current membership tier.');
      }

      // Apply 25% repayment fee
      double repaymentFee = transaction.amount * 0.25;

      // Calculate amount to borrower's wallet (5% of repayment fee)
      double walletAllocation = repaymentFee * 0.05;

      // Calculate amount to investor (95% of repayment fee)
      double investorAmount = repaymentFee - walletAllocation;

      // Update transaction amount (the actual loan amount given to the user)
      // The transaction amount should not be reduced by the repayment fee
      // transaction.amount -= repaymentFee; // This line is incorrect and should be removed

      // Update transaction description
      transaction.description =
          'Loan taken with repayment fee. Repayment Fee: $repaymentFee, Wallet Allocation: $walletAllocation, Investor Amount: $investorAmount';

      // Implement logic to transfer 'walletAllocation' to borrower's wallet
      // Assuming you have a method to update the user's wallet balance
      // and a way to identify the borrower and investor
      String borrowerId = transaction.userId; // Assuming userId is the borrower's ID
      await _updateUserWallet(borrowerId, walletAllocation); // Implement this method

      // Implement logic to transfer 'investorAmount' to investor
      String investorId = transaction.recipientId!; // Assuming recipientId is the investor's ID
      await _transferToInvestor(investorId, investorAmount); // Implement this method
    }

    if (transaction.type == TransactionType.investment && !canMakeInvestment(transaction.amount)) {
      throw Exception('Investment amount exceeds limit for current membership tier.');
    }

    // Check KYC status before processing the transaction
    KYCProvider kycProvider = KYCProvider(); // Instantiate KYCProvider

    if (!kycProvider.isVerified()) {
      throw Exception('User must be KYC verified to perform this transaction.');
    }

    // Integrate escrow system for transaction handling
    Escrow escrow = Escrow(id: transaction.id, initialAmount: transaction.amount);
    escrow.deposit(transaction.amount);

    _transactions.add(transaction);
    transaction.amount = escrow.amount; // Update transaction amount to reflect escrow

    notifyListeners();
  }

  // Add methods to check loan and investment limits based on membership tier
  bool canTakeLoan(double amount) {
    switch (_membershipTier) {
      case MembershipTier.basic:
        return amount <= 500.0;
      case MembershipTier.ambassador:
        return amount <= 1000.0;
      case MembershipTier.vip:
        return amount <= 5000.0;
      case MembershipTier.business:
        return amount <= 10000.0;
    }
  }

  bool canMakeInvestment(double amount) {
    switch (_membershipTier) {
      case MembershipTier.basic:
        return amount <= 5000.0;
      case MembershipTier.ambassador:
        return amount <= 10000.0;
      case MembershipTier.vip:
        return amount <= 50000.0;
      case MembershipTier.business:
        return amount <= 100000.0;
    }
  }

  // Add a method to process loan repayment
  Future<void> processLoanRepayment(Transaction loanTransaction) async {
    if (loanTransaction.type != TransactionType.loan) {
      throw Exception('Invalid transaction type. Expected loan repayment.');
    }

    // Calculate repayment fee (25%)
    double repaymentFee = loanTransaction.amount * 0.25;

    // Calculate amount to borrower's wallet (5% of repayment fee)
    double borrowerWalletAmount = repaymentFee * 0.05;

    // Calculate amount to investor (95% of repayment fee)
    double investorAmount = repaymentFee - borrowerWalletAmount;

    // Update escrow - DEPOSIT the repayment fee
    Escrow escrow = Escrow(id: loanTransaction.id, initialAmount: loanTransaction.amount);
    escrow.deposit(repaymentFee); // Deposit the REPAYMENT FEE

    // Create transactions for repayment fee distribution
    Transaction borrowerWalletTransaction = Transaction(
      id: DateTime.now().toString(),
      userId: loanTransaction.userId,
      amount: borrowerWalletAmount,
      description: 'Loan repayment - Borrower wallet',
      type: TransactionType.commission,
      date: DateTime.now(),
      status: 'completed',
    );

    Transaction investorTransaction = Transaction(
      id: DateTime.now().toString(),
      userId: loanTransaction.userId,
      amount: investorAmount,
      description: 'Loan repayment - Investor',
      type: TransactionType.transfer,
      date: DateTime.now(),
      status: 'completed',
    );

    // Add transactions to the list
    _transactions.add(borrowerWalletTransaction);
    _transactions.add(investorTransaction);

    notifyListeners();
  }

  // Method to update user wallet balance
  Future<void> _updateUserWallet(String userId, double amount) async {
    try {
      await _firestore.collection('users').doc(userId).update({
        'walletBalance': FieldValue.increment(amount),
      });
    } catch (e) {
      throw Exception('Error updating user wallet: $e');
    }
  }

  // Method to transfer amount to investor
  Future<void> _transferToInvestor(String investorId, double amount) async {
    try {
      await _firestore.collection('users').doc(investorId).update({
        'accountBalance': FieldValue.increment(amount),
      });
    } catch (e) {
      throw Exception('Error transferring amount to investor: $e');
    }
  }
}
