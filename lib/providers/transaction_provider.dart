import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/transaction.dart';

class TransactionProvider with ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  String _userId = '';
  List<Transaction> _transactions = [];
  bool _isLoading = false;
  
  // Getters
  String get userId => _userId;
  List<Transaction> get transactions => [..._transactions];
  bool get isLoading => _isLoading;
  
  // Update user ID and load data
  void update(String userId) {
    if (userId.isNotEmpty && userId != _userId) {
      _userId = userId;
      loadTransactions();
    }
  }
  
  // Load transactions from Firestore
  Future<void> loadTransactions() async {
    if (_userId.isEmpty) return;
    
    _setLoading(true);
    
    try {
      final QuerySnapshot transactionSnapshot = await _firestore
          .collection('transactions')
          .where('userId', isEqualTo: _userId)
          .orderBy('timestamp', descending: true)
          .get();
      
      _transactions = transactionSnapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return Transaction.fromMap(doc.id, data);
      }).toList();
    } catch (e) {
      print('Error loading transactions: $e');
    } finally {
      _setLoading(false);
    }
  }
  
  // Set loading state
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }
}