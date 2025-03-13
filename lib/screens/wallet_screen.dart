// File: lib/screens/wallet_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import '../constants/app_colors.dart';
import '../providers/wallet_provider.dart';
import '../providers/transaction_provider.dart';
import '../widgets/custom_button.dart';

class WalletScreen extends StatelessWidget {
  const WalletScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final walletProvider = Provider.of<WalletProvider>(context);
    final transactionProvider = Provider.of<TransactionProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Wallet'),
        backgroundColor: AppColors.primaryBlue,
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await walletProvider.refresh();
          await transactionProvider.loadTransactions();
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Wallet Balance Card
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    gradient: const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        AppColors.primaryBlue,
                        AppColors.primaryPurple,
                      ],
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Wallet Balance',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.white70,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'R${walletProvider.balance.toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _buildBalanceItem(
                            'Invested',
                            'R${walletProvider.totalInvested.toStringAsFixed(2)}',
                            Icons.trending_up,
                          ),
                          _buildBalanceItem(
                            'Borrowed',
                            'R${walletProvider.totalBorrowed.toStringAsFixed(2)}',
                            Icons.trending_down,
                          ),
                          _buildBalanceItem(
                            'Commission',
                            'R${walletProvider.commissionBalance.toStringAsFixed(2)}',
                            Icons.people,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              // Transaction History Header
              const Text(
                'Transaction History',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              _buildTransactionList(transactionProvider),
            ],
          ),
        ),
      ),
    );
  }

  // Helper widget for balance items
  Widget _buildBalanceItem(String title, String amount, IconData icon) {
    return Column(
      children: [
        Icon(
          icon,
          color: Colors.white70,
          size: 20,
        ),
        const SizedBox(height: 4),
        Text(
          title,
          style: const TextStyle(fontSize: 12, color: Colors.white70),
        ),
        const SizedBox(height: 4),
        Text(
          amount,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ],
    );
  }

  // Build transaction list
  Widget _buildTransactionList(TransactionProvider transactionProvider) {
    final transactions = transactionProvider.transactions;

    if (transactions.isEmpty) {
      return const Center(child: Text('No transactions found.'));
    }

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: transactions.length,
      separatorBuilder: (context, index) => const Divider(),
      itemBuilder: (context, index) {
        final txn = transactions[index];
        return ListTile(
          leading: Icon(
            _getTransactionIcon(txn.type),
            color: _getTransactionColor(txn.type),
          ),
          title: Text(txn.description),
          subtitle: Text(DateFormat('dd MMM yyyy, HH:mm').format(txn.date)),
          trailing: Text(
            'R${txn.amount.abs().toStringAsFixed(2)}',
            style: TextStyle(
              color: _getTransactionColor(txn.type),
              fontWeight: FontWeight.bold,
            ),
          ),
        );
      },
    );
  }

  IconData _getTransactionIcon(String type) {
    switch (type) {
      case 'deposit':
        return Icons.arrow_downward;
      case 'withdrawal':
        return Icons.arrow_upward;
      default:
        return Icons.swap_horiz;
    }
  }

  Color _getTransactionColor(String type) {
    switch (type) {
      case 'deposit':
        return AppColors.success;
      case 'withdrawal':
        return AppColors.error;
      default:
        return AppColors.textSecondary;
    }
  }
}
