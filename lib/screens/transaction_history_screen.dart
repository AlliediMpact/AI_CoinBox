import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart'; // Import DateFormat for date formatting

import '../providers/transaction_provider.dart';
import '../models/transaction.dart';
import '../constants/app_colors.dart';

class TransactionHistoryScreen extends StatefulWidget {
  const TransactionHistoryScreen({Key? key}) : super(key: key);

  @override
  _TransactionHistoryScreenState createState() => _TransactionHistoryScreenState();
}

class _TransactionHistoryScreenState extends State<TransactionHistoryScreen> {
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    final transactionProvider = Provider.of<TransactionProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Transaction History'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              transactionProvider.loadTransactions(); // Refresh transactions
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              decoration: InputDecoration(
                labelText: 'Search Transactions',
                border: OutlineInputBorder(),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    setState(() {
                      _searchQuery = '';
                    });
                  },
                ),
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
            ),
          ),
          Expanded(
            child: transactionProvider.transactions.isEmpty
                ? const Center(child: Text('No transactions found.'))
                : ListView.separated(
                    itemCount: transactionProvider.transactions.length,
                    separatorBuilder: (context, index) => const Divider(),
                    itemBuilder: (context, index) {
                      final transaction = transactionProvider.transactions[index];
                      if (_searchQuery.isNotEmpty &&
                          !transaction.description.toLowerCase().contains(_searchQuery.toLowerCase())) {
                        return const SizedBox.shrink(); // Skip this transaction if it doesn't match the search query
                      }
                      return ListTile(
                        title: Text(transaction.description),
                        subtitle: Text(DateFormat('dd MMM yyyy, HH:mm').format(transaction.date)),
                        trailing: Text(
                          'R${transaction.amount.toStringAsFixed(2)}',
                          style: TextStyle(
                            color: _getTransactionColor(transaction.type),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Color _getTransactionColor(dynamic type) {
    switch (type.toString()) {
      case 'TransactionType.deposit':
        return AppColors.success;
      case 'TransactionType.withdrawal':
        return AppColors.error;
      default:
        return AppColors.textSecondary;
    }
  }
}
