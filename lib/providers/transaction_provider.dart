// File: lib/providers/transaction_provider.dart

import 'package:flutter/material.dart';

/// A model representing a single transaction.
class Transaction {
  final String id;
  final double amount;
  final DateTime date;
  final String type; // e.g., 'investment', 'loan', 'commission'

  Transaction({
    required this.id,
    required this.amount,
    required this.date,
    required this.type,
  });
}

class TransactionProvider extends ChangeNotifier {
  // List to hold transactions.
  List<Transaction> _transactions = [];

  // Getter to access the list of transactions.
  List<Transaction> get transactions => _transactions;

  /// Fetches transactions from the backend.
  /// Currently, this method simulates data fetching with dummy data.
  Future<void> fetchTransactions() async {
    // TODO: Replace this simulation with your actual data fetching logic,
    // e.g., querying Firestore for the user's transactions.
    await Future.delayed(const Duration(seconds: 1)); // Simulate network delay

    // Dummy data for demonstration purposes.
    _transactions = [
      Transaction(
        id: 'txn1',
        amount: 100.0,
        date: DateTime.now().subtract(const Duration(days: 1)),
        type: 'investment',
      ),
      Transaction(
        id: 'txn2',
        amount: 50.0,
        date: DateTime.now().subtract(const Duration(days: 2)),
        type: 'loan',
      ),
      Transaction(
        id: 'txn3',
        amount: 20.0,
        date: DateTime.now().subtract(const Duration(days: 3)),
        type: 'commission',
      ),
    ];

    // Notify listeners about the updated data.
    notifyListeners();
  }

  /// Adds a new transaction to the list and notifies listeners.
  void addTransaction(Transaction transaction) {
    _transactions.add(transaction);
    notifyListeners();
  }
}
