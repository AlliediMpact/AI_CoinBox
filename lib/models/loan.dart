import 'package:cloud_firestore/cloud_firestore.dart';

enum LoanStatus { pending, approved, active, completed, defaulted, rejected }

class Loan {
  final String id;
  final String borrowerId;
  final String? lenderId;
  final double amount;
  final double repaymentAmount;
  final DateTime requestDate;
  final DateTime? dueDate;
  final LoanStatus status;
  final double interestRate;
  final Map<String, dynamic>? metadata;

  Loan({
    required this.id,
    required this.borrowerId,
    this.lenderId,
    required this.amount,
    required this.repaymentAmount,
    required this.requestDate,
    this.dueDate,
    required this.status,
    this.interestRate = 0.25, // 25% as per business logic
    this.metadata,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'borrowerId': borrowerId,
        'lenderId': lenderId,
        'amount': amount,
        'repaymentAmount': repaymentAmount,
        'requestDate': Timestamp.fromDate(requestDate),
        'dueDate': dueDate != null ? Timestamp.fromDate(dueDate!) : null,
        'status': status.toString(),
        'interestRate': interestRate,
        'metadata': metadata,
      };

  static Loan fromJson(Map<String, dynamic> json) => Loan(
        id: json['id'],
        borrowerId: json['borrowerId'],
        lenderId: json['lenderId'],
        amount: json['amount'],
        repaymentAmount: json['repaymentAmount'],
        requestDate: (json['requestDate'] as Timestamp).toDate(),
        dueDate: json['dueDate'] != null
            ? (json['dueDate'] as Timestamp).toDate()
            : null,
        status: LoanStatus.values
            .firstWhere((e) => e.toString() == json['status']),
        interestRate: json['interestRate'],
        metadata: json['metadata'],
      );

  DateTime calculateDueDate(int loanTermInDays) {
    return requestDate.add(Duration(days: loanTermInDays));
  }

  // Ensure KYC verification before loan approval
  static Future<void> approveLoan(String loanId) async {
    final loanDoc = await FirebaseFirestore.instance.collection('loans').doc(loanId).get();
    if (!loanDoc.exists) throw Exception('Loan not found');

    final loan = Loan.fromJson(loanDoc.data()!);
    final userDoc = await FirebaseFirestore.instance.collection('users').doc(loan.borrowerId).get();

    if (userDoc.data()?['kycStatus'] != 'verified') {
      throw Exception('Borrower KYC is not verified.');
    }

    await FirebaseFirestore.instance.collection('loans').doc(loanId).update({
      'status': LoanStatus.approved.toString(),
    });
  }
}
