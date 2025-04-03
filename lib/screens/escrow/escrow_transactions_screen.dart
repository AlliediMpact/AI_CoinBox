import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class EscrowTransactionsScreen extends StatelessWidget {
  const EscrowTransactionsScreen({Key? key}) : super(key: key);

  Future<List<Map<String, dynamic>>> _fetchEscrowTransactions(String userId) async {
    final snapshot = await FirebaseFirestore.instance
        .collection('escrow')
        .where('payerId', isEqualTo: userId)
        .get();

    return snapshot.docs.map((doc) => doc.data()).toList();
  }

  @override
  Widget build(BuildContext context) {
    final userId = 'current-user-id'; // Replace with actual user ID

    return Scaffold(
      appBar: AppBar(
        title: const Text('Escrow Transactions'),
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _fetchEscrowTransactions(userId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final transactions = snapshot.data ?? [];

          if (transactions.isEmpty) {
            return const Center(child: Text('No escrow transactions found.'));
          }

          return ListView.builder(
            itemCount: transactions.length,
            itemBuilder: (context, index) {
              final transaction = transactions[index];

              return Card(
                margin: const EdgeInsets.all(8.0),
                child: ListTile(
                  title: Text('Escrow ID: ${transaction['id']}'),
                  subtitle: Text('Amount: R${transaction['amount']}'),
                  trailing: Text(transaction['status']),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
