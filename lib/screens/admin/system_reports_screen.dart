import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fl_chart/fl_chart.dart';

class SystemReportsScreen extends StatelessWidget {
  const SystemReportsScreen({Key? key}) : super(key: key);

  Future<Map<String, dynamic>> _fetchReports() async {
    final usersSnapshot = await FirebaseFirestore.instance.collection('users').get();
    final transactionsSnapshot = await FirebaseFirestore.instance.collection('transactions').get();

    final totalUsers = usersSnapshot.docs.length;
    final totalTransactions = transactionsSnapshot.docs.length;
    final totalTransactionAmount = transactionsSnapshot.docs.fold<double>(
      0.0,
      (sum, doc) => sum + (doc.data()['amount'] ?? 0.0),
    );

    return {
      'totalUsers': totalUsers,
      'totalTransactions': totalTransactions,
      'totalTransactionAmount': totalTransactionAmount,
    };
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('System Reports'),
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: _fetchReports(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final reports = snapshot.data ?? {};

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Total Users: ${reports['totalUsers']}',
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(
                  'Total Transactions: ${reports['totalTransactions']}',
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(
                  'Total Transaction Amount: R${reports['totalTransactionAmount'].toStringAsFixed(2)}',
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 24),
                const Text(
                  'Transaction Trends:',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  height: 200,
                  child: LineChart(
                    LineChartData(
                      lineBarsData: [
                        LineChartBarData(
                          spots: [
                            FlSpot(0, 10),
                            FlSpot(1, 20),
                            FlSpot(2, 30),
                            FlSpot(3, 40),
                          ],
                          isCurved: true,
                          gradient: LinearGradient(colors: [Colors.blue, Colors.blueAccent]), // Replace `colors` with `gradient`
                          barWidth: 4,
                          belowBarData: BarAreaData(show: false),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                const Text(
                  'User Growth:',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  height: 200,
                  child: BarChart(
                    BarChartData(
                      barGroups: [
                        BarChartGroupData(
                          x: 0,
                          barRods: [BarChartRodData(toY: 50, color: Colors.blue)],
                          showingTooltipIndicators: [0],
                        ),
                        BarChartGroupData(
                          x: 1,
                          barRods: [BarChartRodData(toY: 100, color: Colors.green)],
                          showingTooltipIndicators: [0],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
