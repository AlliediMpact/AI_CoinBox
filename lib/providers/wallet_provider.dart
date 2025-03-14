// File: lib/providers/wallet_provider.dart

import 'package:flutter/material.dart';

class WalletProvider extends ChangeNotifier {
  double _balance = 0.0;
  double get balance => _balance;

  /// Deposits funds into the wallet.
  Future<void> deposit(double amount) async {
    // WHY: Update wallet balance after deposit.
    _balance += amount;
    notifyListeners();
  }

  /// Withdraws funds from the wallet.
  Future<void> withdraw(double amount) async {
    if (amount > _balance) {
      throw Exception("Insufficient balance");
    }
    _balance -= amount;
    notifyListeners();
  }
}
