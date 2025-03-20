import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/transaction_provider.dart';
import '../escrow.dart';

class DisputeScreen extends StatefulWidget {
  final Transaction transaction;

  DisputeScreen({required this.transaction});

  @override
  _DisputeScreenState createState() => _DisputeScreenState();
}

class _DisputeScreenState extends State<DisputeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Dispute Resolution'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Transaction ID: ${widget.transaction.id}'),
            Text('Amount: ${widget.transaction.amount}'),
            Text('Description: ${widget.transaction.description}'),
            // Add more transaction details here

            SizedBox(height: 20),

            // User can initiate a dispute
            ElevatedButton(
              onPressed: () {
                // Initiate dispute logic
                _initiateDispute(context, widget.transaction);
              },
              child: Text('Initiate Dispute'),
            ),

            SizedBox(height: 20),

            // Admin section (visible only to admins)
            if (_isAdmin(context))
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Admin Actions', style: TextStyle(fontWeight: FontWeight.bold)),
                  ElevatedButton(
                    onPressed: () {
                      // Resolve dispute in favor of the recipient
                      _resolveDispute(context, widget.transaction, true);
                    },
                    child: Text('Release Funds to Recipient'),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      // Resolve dispute in favor of the sender
                      _resolveDispute(context, widget.transaction, false);
                    },
                    child: Text('Return Funds to Sender'),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  // Function to initiate a dispute
  void _initiateDispute(BuildContext context, Transaction transaction) {
    // TODO: Implement logic to change the escrow status to disputed
    // Update the transaction status and notify listeners
    Escrow escrow = Escrow(id: transaction.id, amount: transaction.amount, senderId: transaction.userId, recipientId: transaction.recipientId ?? '');
    escrow.dispute();
    print('Dispute initiated for transaction ${transaction.id}');
    // Show a confirmation message
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Dispute initiated. An admin will review it.')));
  }

  // Function to resolve a dispute
  void _resolveDispute(BuildContext context, Transaction transaction, bool releaseToRecipient) async {
    // Access the TransactionProvider
    TransactionProvider transactionProvider = Provider.of<TransactionProvider>(context, listen: false);

    // Find the transaction
    Transaction? foundTransaction = transactionProvider.transactions.firstWhere((t) => t.id == transaction.id);

    if (foundTransaction != null) {
      // Resolve the dispute
      Escrow escrow = Escrow(id: transaction.id, amount: transaction.amount, senderId: transaction.userId, recipientId: transaction.recipientId ?? '');
      try {
        await escrow.resolveDispute(releaseToRecipient, transactionProvider._updateUserWallet);

        // Update the transaction status or remove the transaction from the list
        setState(() {
          transactionProvider.loadTransactions();
        });

        // Show a confirmation message
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Dispute resolved.')));
      } catch (e) {
        // Show an error message
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error resolving dispute: $e')));
      }
    } else {
      // Show an error message if the transaction is not found
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Transaction not found.')));
    }
  }


  // Function to check if the user is an admin
  bool _isAdmin(BuildContext context) {
    // TODO: Implement logic to check if the user is an admin
    // This is a placeholder
    return true; // Replace with actual admin check
  }
}
