import 'package:cloud_firestore/cloud_firestore.dart';

enum TransactionType {
  membership,
  loan,
  investment,
  commission,
  withdrawal,
  deposit
}

enum TransactionStatus {
  pending,
  completed,
  failed,
  cancelled
}

class Transaction {
  final String id;
  final String userId;
  final TransactionType type;
  final double amount;
  final String currency;
  final TransactionStatus status;
  final String? reference;
  final DateTime timestamp;
  final Map<String, dynamic>? metadata;

  Transaction({
    required this.id,
    required this.userId,
    required this.type,
    required this.amount,
    this.currency = 'ZAR',
    required this.status,
    this.reference,
    required this.timestamp,
    this.metadata,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'userId': userId,
    'type': type.toString(),
    'amount': amount,
    'currency': currency,
    'status': status.toString(),
    'reference': reference,
    'timestamp': timestamp,
    'metadata': metadata,
  };

  static Transaction fromJson(Map<String, dynamic> json) => Transaction(
    id: json['id'],
    userId: json['userId'],
    type: TransactionType.values.firstWhere(
      (e) => e.toString() == json['type'],
    ),
    amount: json['amount'],
    currency: json['currency'],
    status: TransactionStatus.values.firstWhere(
      (e) => e.toString() == json['status'],
    ),
    reference: json['reference'],
    timestamp: (json['timestamp'] as Timestamp).toDate(),
    metadata: json['metadata'],
  );
}