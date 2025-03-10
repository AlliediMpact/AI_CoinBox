import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/transaction.dart' as app_transaction;

class WalletProvider with ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  String _userId = '';
  double _balance = 0.0;
  double _totalInvested = 0.0;
  double _totalBorrowed = 0.0;
  double _commissionBalance = 0.0;
  bool _isLoading = false;
  
  // Getters
  String get userId => _userId;
  double get balance => _balance;
  double get totalInvested => _totalInvested;
  double get totalBorrowed => _totalBorrowed;
  double get commissionBalance => _commissionBalance;
  bool get isLoading => _isLoading;
  
  // Update user ID and load data
  void update(String userId) {
    if (userId.isNotEmpty && userId != _userId) {
      _userId = userId;
      refresh();
    }
  }
  
  // Refresh wallet data from Firestore
  Future<void> refresh() async {
    if (_userId.isEmpty) {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;
      _userId = user.uid;
    }
    
    _setLoading(true);
    
    try {
      final DocumentSnapshot walletDoc = 
          await _firestore.collection('wallets').doc(_userId).get();
      
      if (walletDoc.exists) {
        final walletData = walletDoc.data() as Map<String, dynamic>;
        
        _balance = (walletData['balance'] ?? 0.0).toDouble();
        _totalInvested = (walletData['totalInvested'] ?? 0.0).toDouble();
        _totalBorrowed = (walletData['totalBorrowed'] ?? 0.0).toDouble();
        _commissionBalance = (walletData['commissionBalance'] ?? 0.0).toDouble();
      } else {
        // Create a new wallet if it doesn't exist
        await _firestore.collection('wallets').doc(_userId).set({
          'balance': 0.0,
          'totalInvested': 0.0,
          'totalBorrowed': 0.0,
          'commissionBalance': 0.0,
          'createdAt': FieldValue.serverTimestamp(),
        });
      }
    } catch (e) {
      print('Error loading wallet data: $e');
    } finally {
      _setLoading(false);
    }
  }
  
  // Add funds to wallet
  Future<bool> addFunds(double amount, String description, String paymentMethod, String? externalTransactionId) async {
    if (_userId.isEmpty || amount <= 0) return false;
    
    _setLoading(true);
    
    try {
      // Update wallet balance
      await _firestore.collection('wallets').doc(_userId).update({
        'balance': FieldValue.increment(amount),
      });
      
      // Create transaction record
      await _firestore.collection('transactions').add({
        'userId': _userId,
        'amount': amount,
        'description': description,
        'type': 'deposit',
        'date': FieldValue.serverTimestamp(),
        'paymentMethod': paymentMethod,
        'externalTransactionId': externalTransactionId,
        'status': 'completed',
      });
      
      // Update local state
      _balance += amount;
      
      _setLoading(false);
      return true;
    } catch (e) {
      print('Error adding funds: $e');
      _setLoading(false);
      return false;
    }
  }
  
  // Withdraw funds from wallet
  Future<bool> withdrawFunds(double amount, String description, String paymentMethod) async {
    if (_userId.isEmpty || amount <= 0 || amount > _balance) return false;
    
    _setLoading(true);
    
    try {
      // Update wallet balance
      await _firestore.collection('wallets').doc(_userId).update({
        'balance': FieldValue.increment(-amount),
      });
      
      // Create transaction record
      await _firestore.collection('transactions').add({
        'userId': _userId,
        'amount': -amount,
        'description': description,
        'type': 'withdrawal',
        'date': FieldValue.serverTimestamp(),
        'paymentMethod': paymentMethod,
        'status': 'pending',
      });
      
      // Update local state
      _balance -= amount;
      
      _setLoading(false);
      return true;
    } catch (e) {
      print('Error withdrawing funds: $e');
      _setLoading(false);
      return false;
    }
  }
  
  // Record an investment
  Future<bool> recordInvestment(double amount, String description) async {
    if (_userId.isEmpty || amount <= 0 || amount > _balance) return false;
    
    _setLoading(true);
    
    try {
      // Update wallet balance and investment total
      await _firestore.collection('wallets').doc(_userId).update({
        'balance': FieldValue.increment(-amount),
        'totalInvested': FieldValue.increment(amount),
      });
      
      // Create transaction record
      await _firestore.collection('transactions').add({
        'userId': _userId,
        'amount': -amount,
        'description': description,
        'type': 'investment',
        'date': FieldValue.serverTimestamp(),
        'status': 'completed',
      });
      
      // Update local state
      _balance -= amount;
      _totalInvested += amount;
      
      _setLoading(false);
      return true;
    } catch (e) {
      print('Error recording investment: $e');
      _setLoading(false);
      return false;
    }
  }
  
  // Record a loan
  Future<bool> recordLoan(double amount, String description) async {
    if (_userId.isEmpty || amount <= 0) return false;
    
    _setLoading(true);
    
    try {
      // Update wallet balance and borrowed total
      await _firestore.collection('wallets').doc(_userId).update({
        'balance': FieldValue.increment(amount),
        'totalBorrowed': FieldValue.increment(amount),
      });
      
      // Create transaction record
      await _firestore.collection('transactions').add({
        'userId': _userId,
        'amount': amount,
        'description': description,
        'type': 'loan',
        'date': FieldValue.serverTimestamp(),
        'status': 'completed',
      });
      
      // Update local state
      _balance += amount;
      _totalBorrowed += amount;
      
      _setLoading(false);
      return true;
    } catch (e) {
      print('Error recording loan: $e');
      _setLoading(false);
      return false;
    }
  }
  
  // Record commission earned
  Future<bool> recordCommission(double amount, String description) async {
    if (_userId.isEmpty || amount <= 0) return false;
    
    _setLoading(true);
    
    try {
      // Update wallet balance and commission total
      await _firestore.collection('wallets').doc(_userId).update({
        'balance': FieldValue.increment(amount),
        'commissionBalance': FieldValue.increment(amount),
      });
      
      // Create transaction record
      await _firestore.collection('transactions').add({
        'userId': _userId,
        'amount': amount,
        'description': description,
        'type': 'commission',
        'date': FieldValue.serverTimestamp(),
        'status': 'completed',
      });
      
      // Update local state
      _balance += amount;
      _commissionBalance += amount;
      
      _setLoading(false);
      return true;
    } catch (e) {
      print('Error recording commission: $e');
      _setLoading(false);
      return false;
    }
  }
  
  // Set loading state
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }
}