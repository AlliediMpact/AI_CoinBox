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

  /// Processes investment interest distribution.
  static Future<void> distributeInvestmentInterest(String investmentId, double investmentAmount) async {
    try {
      // Calculate interest (20% per month)
      double interest = investmentAmount * 0.20;

      // Calculate amount to investor's wallet (5% of interest)
      double investorWalletAmount = interest * 0.05;

      // Calculate amount to investor's bank account (95% of interest)
      double investorBankAccountAmount = interest - investorWalletAmount;

      // Deduct transaction fee (R10)
      double transactionFee = 10.0;
      investorWalletAmount -= transactionFee;

      // Get investor's user ID from investment data
      DocumentSnapshot investmentDoc = await FirebaseFirestore.instance.collection('investments').doc(investmentId).get();
      String investorId = (investmentDoc.data() as Map<String, dynamic>)['userId'];

      // Add interest to investor's wallet
      await FirebaseFirestore.instance.collection('users').doc(investorId).update({
        'walletBalance': FieldValue.increment(investorWalletAmount),
      });

      // Transfer to investor's bank account using a payment gateway
      await transferToBankAccount(investorId, investorBankAccountAmount);

      // Log the interest distribution
      await FirebaseFirestore.instance.collection('transactions').add({
        'userId': investorId,
        'amount': interest,
        'type': 'interest',
        'description': 'Monthly investment interest',
        'date': DateTime.now().toIso8601String(),
        'status': 'completed',
      });
    } catch (e) {
      throw Exception("Error distributing investment interest: $e");
    }
  }

  /// Transfers the investor's amount to their bank account using a payment gateway.
  static Future<void> transferToBankAccount(String investorId, double amount) async {
    try {
      // Simulate payment gateway integration
      // Replace this with actual payment gateway API calls
      print('Transferring $amount to investor $investorId\'s bank account...');
      await Future.delayed(const Duration(seconds: 2)); // Simulate delay
      print('Transfer successful.');
    } catch (e) {
      throw Exception('Error transferring to bank account: $e');
    }
  }

  /// Placeholder for cross-border transactions.
  static Future<void> processCrossBorderTransaction(String userId, double amount, String currency) async {
    try {
      // Simulate cross-border transaction logic
      print('Processing cross-border transaction for $userId: $amount $currency');
      await Future.delayed(const Duration(seconds: 2)); // Simulate delay
      print('Cross-border transaction successful.');
    } catch (e) {
      throw Exception('Error processing cross-border transaction: $e');
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
