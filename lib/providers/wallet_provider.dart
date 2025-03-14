// File: lib/providers/wallet_provider.dart

import 'package:flutter/material.dart';

class WalletProvider extends ChangeNotifier {
  // Main wallet balance
  double balance = 0.0;
  
  // Private variables for totals
  double _totalInvested = 0.0;
  double _totalBorrowed = 0.0;
  double _commissionBalance = 0.0;

  // Getters to expose private totals
  double get totalInvested => _totalInvested;
  double get totalBorrowed => _totalBorrowed;
  double get commissionBalance => _commissionBalance;

  /// Refreshes the wallet data from the backend.
  /// For now, this simulates data fetching with dummy data.
  Future<void> refresh() async {
    // TODO: Replace this simulation with your actual data fetching logic,
    // e.g., querying Firestore for the latest wallet details.
    await Future.delayed(const Duration(seconds: 1)); // Simulate network delay

    // Dummy data for demonstration purposes.
    balance = 1000.0;
    _totalInvested = 500.0;
    _totalBorrowed = 300.0;
    _commissionBalance = 200.0;

    // Notify listeners about the updated data.
    notifyListeners();
  }
}
