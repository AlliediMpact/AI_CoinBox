import 'package:flutter/material.dart';

class Escrow {
  final String id;
  double _amount;
  String? _transactionId;
  bool _isReleased = false;

  Escrow({
    required this.id,
    required double initialAmount,
  }) : _amount = initialAmount;

  double get amount => _amount;
  bool get isReleased => _isReleased;

  void deposit(double amount) {
    if (_isReleased) {
      throw Exception('Funds have already been released.');
    }
    _amount += amount;
  }

  void release(String transactionId) {
    if (_isReleased) {
      throw Exception('Funds have already been released.');
    }
    _transactionId = transactionId;
    _isReleased = true;
  }

  void refund() {
    if (_isReleased) {
      throw Exception('Cannot refund released funds.');
    }
    _amount = 0.0; // Reset amount on refund
  }
}
