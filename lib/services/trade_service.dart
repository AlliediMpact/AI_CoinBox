// File: lib/services/trade_service.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/investment.dart';
import '../models/loan.dart';

class TradeService {
  /// Retrieves a list of investments from Firestore.
  static Future<List<Investment>> getInvestments() async {
    try {
      QuerySnapshot snapshot =
          await FirebaseFirestore.instance.collection('investments').get();
      return snapshot.docs
          .map((doc) => Investment.fromMap(doc.data() as Map<String, dynamic>, doc.id))
          .toList();

    } catch (e) {
      throw Exception("Error fetching investments: $e");
    }
  }

  /// Retrieves a list of loans from Firestore.
  static Future<List<Loan>> getLoans() async {
    try {
      QuerySnapshot snapshot =
          await FirebaseFirestore.instance.collection('loans').get();
      return snapshot.docs
          .map((doc) => Loan.fromMap(doc.data() as Map<String, dynamic>, doc.id))
          .toList();

    } catch (e) {
      throw Exception("Error fetching loans: $e");
    }
  }

  /// Processes an investment transaction.
  static Future<void> processInvestment(Map<String, dynamic> investmentData) async {
    try {
      await FirebaseFirestore.instance.collection('investments').add(investmentData);
    } catch (e) {
      throw Exception("Error processing investment: $e");
    }
  }

  /// Processes a loan transaction.
  static Future<void> processLoan(Map<String, dynamic> loanData) async {
    try {
      await FirebaseFirestore.instance.collection('loans').add(loanData);
    } catch (e) {
      throw Exception("Error processing loan: $e");
    }
  }

  /// Retrieves the user's membership plan from Firestore.
  static Future<String> getUserMembershipPlan(String uid) async {
    try {
      DocumentSnapshot doc =
          await FirebaseFirestore.instance.collection('users').doc(uid).get();
      return (doc.data() as Map<String, dynamic>)['membershipTier'] ?? 'basic';
    } catch (e) {
      throw Exception("Error fetching membership plan: $e");
    }
  }
}
