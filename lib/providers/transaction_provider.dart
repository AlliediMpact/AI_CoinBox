// File: lib/providers/transaction_provider.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../models/transaction.dart' as CustomTransaction;

class TransactionProvider extends ChangeNotifier {
  List<CustomTransaction.Transaction> _transactions = [];

  List<CustomTransaction.Transaction> get transactions => _transactions;

  /// Refreshes the transaction list from Firestore.
  Future<void> refresh() async {
    try {
      QuerySnapshot snapshot =
          await FirebaseFirestore.instance.collection('transactions').get();
      _transactions = snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return CustomTransaction.Transaction.fromMap(doc.id, data);
      }).toList();
      notifyListeners();
    } catch (e) {
      throw Exception("Error refreshing transactions: $e");
    }
  }
}
