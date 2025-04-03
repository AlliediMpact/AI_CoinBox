import 'package:cloud_firestore/cloud_firestore.dart';

enum InvestmentStatus { pending, active, completed, cancelled }

class Investment {
  final String id;
  final String investorId;
  final double amount;
  final DateTime startDate;
  final DateTime? endDate;
  final InvestmentStatus status;
  final double monthlyInterestRate;
  final double totalReturns;
  final List<String> earningsHistory;
  final Map<String, dynamic>? metadata;

  Investment({
    required this.id,
    required this.investorId,
    required this.amount,
    required this.startDate,
    this.endDate,
    required this.status,
    this.monthlyInterestRate = 0.20, // 20% monthly as per business logic
    this.totalReturns = 0.0,
    List<String>? earningsHistory,
    this.metadata,
  }) : this.earningsHistory = earningsHistory ?? [];

  Map<String, dynamic> toJson() => {
        'id': id,
        'investorId': investorId,
        'amount': amount,
        'startDate': Timestamp.fromDate(startDate),
        'endDate': endDate != null ? Timestamp.fromDate(endDate!) : null,
        'status': status.toString(),
        'monthlyInterestRate': monthlyInterestRate,
        'totalReturns': totalReturns,
        'earningsHistory': earningsHistory,
        'metadata': metadata,
      };

  static Investment fromJson(Map<String, dynamic> json) => Investment(
        id: json['id'],
        investorId: json['investorId'],
        amount: json['amount'],
        startDate: (json['startDate'] as Timestamp).toDate(),
        endDate: json['endDate'] != null
            ? (json['endDate'] as Timestamp).toDate()
            : null,
        status: InvestmentStatus.values
            .firstWhere((e) => e.toString() == json['status']),
        monthlyInterestRate: json['monthlyInterestRate'],
        totalReturns: json['totalReturns'],
        earningsHistory: List<String>.from(json['earningsHistory'] ?? []),
        metadata: json['metadata'],
      );

  double calculateMonthlyReturns() {
    return amount * monthlyInterestRate;
  }

  // Ensure KYC verification before investment creation
  static Future<void> createInvestment(String investorId, double amount) async {
    final userDoc = await FirebaseFirestore.instance.collection('users').doc(investorId).get();

    if (userDoc.data()?['kycStatus'] != 'verified') {
      throw Exception('Investor KYC is not verified.');
    }

    // ...existing investment creation logic...
  }
}
