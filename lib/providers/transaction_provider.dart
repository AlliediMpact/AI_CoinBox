// File: lib/providers/transaction_provider.dart
import 'package:flutter/material.dart';
// Import your custom Transaction model, alias if necessary
import '../models/transaction.dart' as CustomTransaction;
import 'package:cloud_firestore/cloud_firestore.dart';

class TransactionProvider extends ChangeNotifier {
  List<CustomTransaction.Transaction> transactions = [];

  Future<void> loadTransactions() async {
    try {
      QuerySnapshot snapshot = await FirebaseFirestore.instance.collection('transactions').get();
      transactions = snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return CustomTransaction.Transaction.fromMap(doc.id, data);
      }).toList();
      notifyListeners();
    } catch (e) {
      throw Exception("Error loading transactions: $e");
    }
  }
}
