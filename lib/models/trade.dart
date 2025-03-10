import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/firebase_service.dart';

class Trade {
  final String? id;
  final String investorId;
  final String borrowerId;
  final String investmentId;
  final String loanId;
  final double tradeAmount;
  final String status;
  final DateTime createdAt;

  Trade({
    this.id,
    required this.investorId,
    required this.borrowerId,
    required this.investmentId,
    required this.loanId,
    required this.tradeAmount,
    required this.status,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'investorId': investorId,
      'borrowerId': borrowerId,
      'investmentId': investmentId,
      'loanId': loanId,
      'tradeAmount': tradeAmount,
      'status': status,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  static Future<void> create(Trade trade) async {
    await FirebaseService.firestore
        .collection('trades')
        .add(trade.toMap());
  }

  factory Trade.fromMap(Map<String, dynamic> map, String id) {
    return Trade(
      id: id,
      investorId: map['investorId'],
      borrowerId: map['borrowerId'],
      investmentId: map['investmentId'],
      loanId: map['loanId'],
      tradeAmount: map['tradeAmount'],
      status: map['status'],
      createdAt: DateTime.parse(map['createdAt']),
    );
  }
}
