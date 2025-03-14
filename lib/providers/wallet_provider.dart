// File: lib/providers/wallet_provider.dart
import 'package:flutter/material.dart';

class WalletProvider extends ChangeNotifier {
  double balance = 0.0;
  double _totalInvested = 0.0;
  double _totalBorrowed = 0.0;
  double _commissionBalance = 0.0;

  double get totalInvested => _totalInvested;
  double get totalBorrowed => _totalBorrowed;
  double get commissionBalance => _commissionBalance;

  Future<void> refresh() async {
    // Implement logic to refresh wallet data
    // For example, fetch data from Firestore and update properties.
    notifyListeners();
  }
}
