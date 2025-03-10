import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/firebase_service.dart';

class Loan {
  final String? id;
  final String userId;
  final double amount;
  final String status;
  final DateTime createdAt;
  final DateTime repaymentDate;
  final double repaymentFee;
  final String? tradeId;
  final String? investmentId;
  final DateTime? matchedAt;

  Loan({
    this.id,
    required this.userId,
    required this.amount,
    required this.status,
    required this.createdAt,
    required this.repaymentDate,
    required this.repaymentFee,
    this.tradeId,
    this.investmentId,
    this.matchedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'amount': amount,
      'status': status,
      'createdAt': createdAt.toIso8601String(),
      'repaymentDate': repaymentDate.toIso8601String(),
      'repaymentFee': repaymentFee,
      'tradeId': tradeId,
      'investmentId': investmentId,
      'matchedAt': matchedAt?.toIso8601String(),
    };
  }

  static Future<void> create(Loan loan) async {
    await FirebaseService.firestore
        .collection('loans')
        .add(loan.toMap());
  }

  static Stream<QuerySnapshot> getLoansByUser(String userId) {
    return FirebaseService.firestore
        .collection('loans')
        .where('userId', isEqualTo: userId)
        .snapshots();
  }

  factory Loan.fromMap(Map<String, dynamic> map, String id) {
    return Loan(
      id: id,
      userId: map['userId'],
      amount: map['amount'],
      status: map['status'],
      createdAt: DateTime.parse(map['createdAt']),
      repaymentDate: DateTime.parse(map['repaymentDate']),
      repaymentFee: map['repaymentFee'],
      tradeId: map['tradeId'],
      investmentId: map['investmentId'],
      matchedAt: map['matchedAt'] != null ? DateTime.parse(map['matchedAt']) : null,
    );
  }
}
