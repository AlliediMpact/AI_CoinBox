import 'package:cloud_firestore/cloud_firestore.dart';

// Define transaction types as an enum for type safety
enum TransactionType {
  deposit,
  withdrawal,
  investment,
  loan,
  commission,
  transfer,
  fee
}

// Extension to add string conversion methods to the enum
extension TransactionTypeExtension on TransactionType {
  String toShortString() {
    return toString().split('.').last;
  }
  
  String toUpperCase() {
    return toString().split('.').last.toUpperCase();
  }
  
  static TransactionType fromString(String value) {
    return TransactionType.values.firstWhere(
      (type) => type.toShortString() == value,
      orElse: () => TransactionType.fee,
    );
  }
}

class Transaction {
  final String id;
  final String userId;
  final double amount;
  final String description;
  final TransactionType type;
  final DateTime date;
  final String status;
  final String? paymentMethod;
  final String? externalTransactionId;
  final String? recipientId;
  final String? senderId;
  
  Transaction({
    required this.id,
    required this.userId,
    required this.amount,
    required this.description,
    required this.type,
    required this.date,
    required this.status,
    this.paymentMethod,
    this.externalTransactionId,
    this.recipientId,
    this.senderId,
  });
  
  // Factory constructor to create a Transaction from a Firestore document
  factory Transaction.fromMap(String docId, Map<String, dynamic> data) {
    return Transaction(
      id: docId,
      userId: data['userId'] ?? '',
      amount: (data['amount'] ?? 0.0).toDouble(),
      description: data['description'] ?? '',
      type: TransactionTypeExtension.fromString(data['type'] ?? ''),
      date: (data['date'] as Timestamp?)?.toDate() ?? DateTime.now(),
      status: data['status'] ?? 'pending',
      paymentMethod: data['paymentMethod'],
      externalTransactionId: data['externalTransactionId'],
      recipientId: data['recipientId'],
      senderId: data['senderId'],
    );
  }
  
  // Convert Transaction to a Map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'amount': amount,
      'description': description,
      'type': type.toShortString(),
      'date': Timestamp.fromDate(date),
      'status': status,
      if (paymentMethod != null) 'paymentMethod': paymentMethod,
      if (externalTransactionId != null) 'externalTransactionId': externalTransactionId,
      if (recipientId != null) 'recipientId': recipientId,
      if (senderId != null) 'senderId': senderId,
    };
  }
  
  // Create a copy of this Transaction with modified fields
  Transaction copyWith({
    String? id,
    String? userId,
    double? amount,
    String? description,
    TransactionType? type,
    DateTime? date,
    String? status,
    String? paymentMethod,
    String? externalTransactionId,
    String? recipientId,
    String? senderId,
  }) {
    return Transaction(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      amount: amount ?? this.amount,
      description: description ?? this.description,
      type: type ?? this.type,
      date: date ?? this.date,
      status: status ?? this.status,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      externalTransactionId: externalTransactionId ?? this.externalTransactionId,
      recipientId: recipientId ?? this.recipientId,
      senderId: senderId ?? this.senderId,
    );
  }
}