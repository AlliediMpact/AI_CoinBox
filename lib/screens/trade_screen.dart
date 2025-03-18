// File: lib/screens/trade_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../constants/app_colors.dart';
import '../services/trade_service.dart';
import '../providers/transaction_provider.dart';

class TradeScreen extends StatefulWidget {
  const TradeScreen({Key? key}) : super(key: key);

  @override
  _TradeScreenState createState() => _TradeScreenState();
}

class _TradeScreenState extends State<TradeScreen> {
  bool _isLoading = false;
  List<dynamic> _investments = [];
  List<dynamic> _loans = [];

  @override
  void initState() {
    super.initState();
    _fetchTradeData();
  }

  Future<void> _fetchTradeData() async {
    setState(() {
      _isLoading = true;
    });
    try {
      _investments = await TradeService.getInvestments();
      _loans = await TradeService.getLoans();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching trade data: $e')),
      );
    }
    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final transactionProvider = Provider.of<TransactionProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Trading'),
        backgroundColor: AppColors.primaryBlue,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _fetchTradeData,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                physics: const AlwaysScrollableScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Investments Section
                    const Text(
                      'Investments',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    _buildInvestmentList(),
                    const SizedBox(height: 24),
                    // Loans Section
                    const Text(
                      'Loans',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    _buildLoanList(),
                  ],
                ),
              ),
            ),
      bottomNavigationBar: _buildBottomNavBar(),
    );
  }

  // Build the list of investments
  Widget _buildInvestmentList() {
    if (_investments.isEmpty) {
      return const Text('No investments available.');
    }
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _investments.length,
      itemBuilder: (context, index) {
        final inv = _investments[index];
        return Card(
          margin: const EdgeInsets.symmetric(vertical: 8),
          child: ListTile(
            title: Text(inv.title ?? 'Investment ${index + 1}'),
            subtitle: Text('Amount: R${inv.amount} | Return: 20% per month'),
            trailing: ElevatedButton(
              onPressed: () {
                // Process investment action here
              },
              child: const Text('Invest'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.success,
              ),

            ),
          ),
        );
      },
    );
  }

  // Build the list of loans
  Widget _buildLoanList() {
    if (_loans.isEmpty) {
      return const Text('No loans available.');
    }
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _loans.length,
      itemBuilder: (context, index) {
        final loan = _loans[index];
        return Card(
          margin: const EdgeInsets.symmetric(vertical: 8),
          child: ListTile(
            title: Text(loan.title ?? 'Loan ${index + 1}'),
            subtitle: Text('Amount: R${loan.amount} | Fee: 20%'),
            trailing: ElevatedButton(
              onPressed: () {
                // Process loan action here
              },
              child: const Text('Borrow'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.warning,
              ),

            ),
          ),
        );
      },
    );
  }

  // Bottom navigation for trade screen
  Widget _buildBottomNavBar() {
    return BottomNavigationBar(
      currentIndex: 2, // Trade screen index
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
        BottomNavigationBarItem(icon: Icon(Icons.account_balance_wallet), label: 'Wallet'),
        BottomNavigationBarItem(icon: Icon(Icons.swap_horiz), label: 'Trading'),
        BottomNavigationBarItem(icon: Icon(Icons.people), label: 'Referrals'),
      ],
      onTap: (index) {
        // Implement navigation logic based on the tapped index
      },
    );
  }
}
