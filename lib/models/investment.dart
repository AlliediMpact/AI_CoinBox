import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/firebase_service.dart';

class Investment {
  final String? id;
  final String userId;
  final double amount;
  final String status;
  final DateTime createdAt;
  final DateTime maturityDate;
  final String? tradeId;
  final String? loanId;
  final DateTime? matchedAt;

  Investment({
    this.id,
    required this.userId,
    required this.amount,
    required this.status,
    required this.createdAt,
    required this.maturityDate,
    this.tradeId,
    this.loanId,
    this.matchedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'amount': amount,
      'status': status,
      'createdAt': createdAt.toIso8601String(),
      'maturityDate': maturityDate.toIso8601String(),
      'tradeId': tradeId,
      'loanId': loanId,
      'matchedAt': matchedAt?.toIso8601String(),
    };
  }

  static Future<void> create(Investment investment) async {
    await FirebaseService.firestore
        .collection('investments')
        .add(investment.toMap());
  }

  static Stream<QuerySnapshot> getInvestmentsByUser(String userId) {
    return FirebaseService.firestore
        .collection('investments')
        .where('userId', isEqualTo: userId)
        .snapshots();
  }

  factory Investment.fromMap(Map<String, dynamic> map, String id) {
    return Investment(
      id: id,
      userId: map['userId'],
      amount: map['amount'],
      status: map['status'],
      createdAt: DateTime.parse(map['createdAt']),
      maturityDate: DateTime.parse(map['maturityDate']),
      tradeId: map['tradeId'],
      loanId: map['loanId'],
      matchedAt: map['matchedAt'] != null ? DateTime.parse(map['matchedAt']) : null,
    );
  }
}
