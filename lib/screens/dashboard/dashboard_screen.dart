import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../services/financial_service.dart';
import '../../services/kyc_service.dart';
import '../transactions/transaction_history_screen.dart';
import '../kyc/kyc_screen.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({Key? key}) : super(key: key);

  Future<Map<String, dynamic>> _fetchDashboardData(String userId) async {
    try {
      final referralStats = await FinancialService.getReferralStats(userId);
      final loansSnapshot = await FirebaseFirestore.instance
          .collection('loans')
          .where('borrowerId', isEqualTo: userId)
          .get();
      final investmentsSnapshot = await FirebaseFirestore.instance
          .collection('investments')
          .where('investorId', isEqualTo: userId)
          .get();

      return {
        'referralStats': referralStats,
        'totalLoans': loansSnapshot.docs.length,
        'totalInvestments': investmentsSnapshot.docs.length,
        'totalLoanAmount': loansSnapshot.docs.fold<double>(
          0.0,
          (sum, doc) => sum + (doc.data()['amount'] ?? 0.0),
        ),
        'totalInvestmentAmount': investmentsSnapshot.docs.fold<double>(
          0.0,
          (sum, doc) => sum + (doc.data()['amount'] ?? 0.0),
        ),
      };
    } catch (e) {
      print('Error fetching dashboard data: $e');
      rethrow;
    }
  }

  @override
  Widget build(BuildContext context) {
    print('Rendering DashboardScreen');
    final userId = FirebaseAuth.instance.currentUser?.uid;

    if (userId == null) {
      return const Scaffold(
        body: Center(child: Text('User not signed in.')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        backgroundColor: const Color(0xFF193281),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Wallet Card
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    const Text(
                      'Wallet Balance',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    FutureBuilder<DocumentSnapshot>(
                      future: FirebaseFirestore.instance
                          .collection('wallets')
                          .doc(userId)
                          .get(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return const CircularProgressIndicator();
                        }
                        if (snapshot.hasError) {
                          return Text('Error: ${snapshot.error}');
                        }
                        final walletData =
                            snapshot.data?.data() as Map<String, dynamic>?;
                        final walletBalance = walletData?['balance'] ?? 0.0;
                        return Text(
                          'R${walletBalance.toStringAsFixed(2)}',
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF5e17eb),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        ElevatedButton.icon(
                          onPressed: () {}, // Add Funds logic
                          icon: const Icon(Icons.add),
                          label: const Text('Add Funds'),
                        ),
                        ElevatedButton.icon(
                          onPressed: () {}, // Withdraw logic
                          icon: const Icon(Icons.remove),
                          label: const Text('Withdraw'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            // Financial Insights Chart
            const Text(
              'Financial Insights',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            SizedBox(
              height: 200,
              child: FutureBuilder<Map<String, dynamic>>(
                future: _fetchDashboardData(userId),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  }
                  if (!snapshot.hasData || snapshot.data == null) {
                    return const Center(child: Text('No data available.'));
                  }

                  final data = snapshot.data!;
                  final totalLoanAmount = data['totalLoanAmount'] ?? 0.0;
                  final totalInvestmentAmount = data['totalInvestmentAmount'] ?? 0.0;

                  return PieChart(
                    PieChartData(
                      sections: [
                        PieChartSectionData(
                          value: totalLoanAmount,
                          title: 'Loans',
                          color: Colors.blue,
                        ),
                        PieChartSectionData(
                          value: totalInvestmentAmount,
                          title: 'Investments',
                          color: Colors.green,
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 16),
            // Quick Actions
            const Text(
              'Quick Actions',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton.icon(
                  onPressed: () {}, // Loan Request logic
                  icon: const Icon(Icons.request_page),
                  label: const Text('Request Loan'),
                ),
                ElevatedButton.icon(
                  onPressed: () {}, // Create Investment logic
                  icon: const Icon(Icons.trending_up),
                  label: const Text('Invest'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
