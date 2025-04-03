import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/firebase_service.dart';

class Wallet {
  final String userId;
  double _balance;
  final double commissionBalance;
  final DateTime lastUpdated;

  Wallet({
    required this.userId,
    required double balance,
    required this.commissionBalance,
    required this.lastUpdated,
  }) : _balance = balance;

  double get balance => _balance;

  set balance(double newBalance) {
    if (newBalance < 0) {
      throw Exception('Balance cannot be negative.');
    }
    _balance = newBalance;
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'balance': _balance,
      'commissionBalance': commissionBalance,
      'lastUpdated': lastUpdated.toIso8601String(),
    };
  }

  factory Wallet.fromMap(Map<String, dynamic> map) {
    return Wallet(
      userId: map['userId'],
      balance: map['balance'],
      commissionBalance: map['commissionBalance'],
      lastUpdated: DateTime.parse(map['lastUpdated']),
    );
  }

  static Future<void> updateBalance(String userId, double amount) async {
    if (amount < 0) {
      throw Exception('Balance update cannot be negative.');
    }

    final walletRef = FirebaseService.firestore.collection('wallets').doc(userId);
    
    await FirebaseService.firestore.runTransaction((transaction) async {
      final walletDoc = await transaction.get(walletRef);
      
      if (!walletDoc.exists) {
        transaction.set(walletRef, {
          'userId': userId,
          'balance': amount,
          'commissionBalance': 0.0,
          'lastUpdated': DateTime.now().toIso8601String(),
        });
      } else {
        final currentBalance = (walletDoc.data()?['balance'] ?? 0.0) as double;
        transaction.update(walletRef, {
          'balance': currentBalance + amount,
          'lastUpdated': DateTime.now().toIso8601String(),
        });
      }
    });
  }

  static Stream<DocumentSnapshot> getWalletStream(String userId) {
    return FirebaseService.firestore
        .collection('wallets')
        .doc(userId)
        .snapshots();
  }
}
