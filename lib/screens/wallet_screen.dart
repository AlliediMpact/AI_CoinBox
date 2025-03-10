import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/wallet_provider.dart';
import '../providers/transaction_provider.dart';
import '../models/transaction.dart' as model;
import '../widgets/custom_button.dart';
import '../constants/app_colors.dart';
import '../utils/error_handler.dart';

class WalletScreen extends StatefulWidget {
  const WalletScreen({Key? key}) : super(key: key);

  @override
  State<WalletScreen> createState() => _WalletScreenState();
}

class _WalletScreenState extends State<WalletScreen> {
  final _depositAmountController = TextEditingController();
  final _withdrawalAmountController = TextEditingController();
  final _accountDetailsController = TextEditingController();
  String _selectedPaymentMethod = 'Bank Transfer';
  bool _isProcessing = false;

  @override
  void dispose() {
    _depositAmountController.dispose();
    _withdrawalAmountController.dispose();
    _accountDetailsController.dispose();
    super.dispose();
  }

  // Show deposit dialog
  void _showDepositDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Deposit Funds'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _depositAmountController,
                decoration: const InputDecoration(
                  labelText: 'Amount (R)',
                  hintText: 'Enter amount to deposit',
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _selectedPaymentMethod,
                decoration: const InputDecoration(
                  labelText: 'Payment Method',
                ),
                items: ['Bank Transfer', 'Credit Card', 'PayPal', 'Other']
                    .map((method) => DropdownMenuItem(
                          value: method,
                          child: Text(method),
                        ))
                    .toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      _selectedPaymentMethod = value;
                    });
                  }
                },
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
            },
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: _isProcessing
                ? null
                : () {
                    _processDeposit();
                    Navigator.of(ctx).pop();
                  },
            child: _isProcessing
                ? const CircularProgressIndicator()
                : const Text('Deposit'),
          ),
        ],
      ),
    );
  }

  // Show withdrawal dialog
  void _showWithdrawalDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Withdraw Funds'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _withdrawalAmountController,
                decoration: const InputDecoration(
                  labelText: 'Amount (R)',
                  hintText: 'Enter amount to withdraw',
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _selectedPaymentMethod,
                decoration: const InputDecoration(
                  labelText: 'Payment Method',
                ),
                items: ['Bank Transfer', 'PayPal', 'Other']
                    .map((method) => DropdownMenuItem(
                          value: method,
                          child: Text(method),
                        ))
                    .toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      _selectedPaymentMethod = value;
                    });
                  }
                },
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _accountDetailsController,
                decoration: const InputDecoration(
                  labelText: 'Account Details',
                  hintText: 'Enter your account details',
                ),
                maxLines: 3,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
            },
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: _isProcessing
                ? null
                : () {
                    _processWithdrawal();
                    Navigator.of(ctx).pop();
                  },
            child: _isProcessing
                ? const CircularProgressIndicator()
                : const Text('Withdraw'),
          ),
        ],
      ),
    );
  }

  // Process deposit
  Future<void> _processDeposit() async {
    final amountText = _depositAmountController.text.trim();
    if (amountText.isEmpty) {
      ErrorHandler.showErrorSnackBar(
        context,
        'Please enter an amount',
      );
      return;
    }

    final amount = double.tryParse(amountText);
    if (amount == null || amount <= 0) {
      ErrorHandler.showErrorSnackBar(
        context,
        'Please enter a valid amount',
      );
      return;
    }

    setState(() {
      _isProcessing = true;
    });

    try {
      // In a real app, you would integrate with a payment gateway here
      // For now, we'll simulate a successful payment
      final transactionId = 'sim_${DateTime.now().millisecondsSinceEpoch}';
      
      // Process the deposit
      await Provider.of<WalletProvider>(context, listen: false).deposit(
        amount,
        _selectedPaymentMethod,
        transactionId,
      );
      
      // Refresh transactions
      await Provider.of<TransactionProvider>(context, listen: false).refresh();
      
      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Successfully deposited R${amount.toStringAsFixed(2)}'),
          backgroundColor: Colors.green,
        ),
      );
      
      // Clear form
      _depositAmountController.clear();
    } catch (e, stackTrace) {
      ErrorHandler.logError(e, stackTrace: stackTrace);
      ErrorHandler.showErrorDialog(
        context,
        'Failed to process deposit. Please try again.',
      );
    } finally {
      setState(() {
        _isProcessing = false;
      });
    }
  }

  // Process withdrawal
  Future<void> _processWithdrawal() async {
    final amountText = _withdrawalAmountController.text.trim();
    if (amountText.isEmpty) {
      ErrorHandler.showErrorSnackBar(
        context,
        'Please enter an amount',
      );
      return;
    }

    final amount = double.tryParse(amountText);
    if (amount == null || amount <= 0) {
      ErrorHandler.showErrorSnackBar(
        context,
        'Please enter a valid amount',
      );
      return;
    }

    final accountDetails = _accountDetailsController.text.trim();
    if (accountDetails.isEmpty) {
      ErrorHandler.showErrorSnackBar(
        context,
        'Please enter your account details',
      );
      return;
    }

    setState(() {
      _isProcessing = true;
    });

    try {
      // Check if user has sufficient balance
      final walletProvider = Provider.of<WalletProvider>(context, listen: false);
      if (amount > walletProvider.balance) {
        ErrorHandler.showErrorDialog(
          context,
          'Insufficient funds. Your current balance is R${walletProvider.balance.toStringAsFixed(2)}',
        );
        return;
      }
      
      // Process the withdrawal
      await walletProvider.withdraw(
        amount,
        _selectedPaymentMethod,
        accountDetails,
      );
      
      // Refresh transactions
      await Provider.of<TransactionProvider>(context, listen: false).refresh();
      
      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Withdrawal request for R${amount.toStringAsFixed(2)} has been submitted'),
          backgroundColor: Colors.green,
        ),
      );
      
      // Clear form
      _withdrawalAmountController.clear();
      _accountDetailsController.clear();
    } catch (e, stackTrace) {
      ErrorHandler.logError(e, stackTrace: stackTrace);
      ErrorHandler.showErrorDialog(
        context,
        'Failed to process withdrawal. Please try again.',
      );
    } finally {
      setState(() {
        _isProcessing = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Wallet'),
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await Provider.of<WalletProvider>(context, listen: false).refresh();
          await Provider.of<TransactionProvider>(context, listen: false).refresh();
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Wallet balance card
                _buildWalletCard(),
                
                const SizedBox(height: 24),
                
                // Action buttons
                Row(
                  children: [
                    Expanded(
                      child: CustomButton(
                        text: 'Deposit',
                        onPressed: _showDepositDialog,
                        backgroundColor: AppColors.success,
                        icon: Icons.arrow_downward,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: CustomButton(
                        text: 'Withdraw',
                        onPressed: _showWithdrawalDialog,
                        backgroundColor: AppColors.error,
                        icon: Icons.arrow_upward,
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 24),
                
                // Transaction history
                const Text(
                  'Transaction History',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                _buildTransactionList(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Build wallet card
  Widget _buildWalletCard() {
    final walletProvider = Provider.of<WalletProvider>(context);
    
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Current Balance',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 8),
            walletProvider.isLoading
                ? const CircularProgressIndicator()
                : Text(
                    'R${walletProvider.balance.toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primaryBlue,
                    ),
                  ),
            const SizedBox(height: 16),
            const Text(
              'Available for withdrawal, investment, or loan repayment',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Build transaction list
  Widget _buildTransactionList() {
    final transactionProvider = Provider.of<TransactionProvider>(context);
    final transactions = transactionProvider.transactions;
    
    if (transactionProvider.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    
    if (transactions.isEmpty) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Text('No transactions yet'),
        ),
      );
    }
    
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: transactions.length,
      itemBuilder: (context, index) {
        final transaction = transactions[index];
        return _buildTransactionItem(transaction);
      },
    );
  }

  // Build transaction item
  Widget _buildTransactionItem(model.Transaction transaction) {
    IconData icon;
    Color color;
    
    switch (transaction.type) {
      case 'deposit':
        icon = Icons.arrow_downward;
        color = AppColors.success;
        break;
      case 'withdrawal':
        icon = Icons.arrow_upward;
        color = AppColors.error;
        break;
      case 'investment':
        icon = Icons.trending_up;
        color = AppColors.warning;
        break;
      case 'loan':
        icon = Icons.money;
        color = AppColors.info;
        break;
      case 'commission':
        icon = Icons.star;
        color = AppColors.success;
        break;
      default:
        icon = Icons.swap_horiz;
        color = AppColors.primaryBlue;
    }
    
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: color.withOpacity(0.2),
          child: Icon(icon, color: color),
        ),
        title: Text(transaction.description),
        subtitle: Text(
          '${transaction.date.day}/${transaction.date.month}/${transaction.date.year} • ${transaction.status}',
        ),
        trailing: Text(
          'R${transaction.amount.abs().toStringAsFixed(2)}',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: transaction.amount >= 0 ? AppColors.success : AppColors.error,
          ),
        ),
        onTap: () => _showTransactionDetails(transaction),
      ),
    );
  }

  // Show transaction details
  void _showTransactionDetails(model.Transaction transaction) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Transaction Details'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDetailRow('Type', transaction.type.toUpperCase()),
            _buildDetailRow('Amount', 'R${transaction.amount.abs().toStringAsFixed(2)}'),
            _buildDetailRow('Description', transaction.description),
            _buildDetailRow('Date', '${transaction.date.day}/${transaction.date.month}/${transaction.date.year}'),
            _buildDetailRow('Time', '${transaction.date.hour}:${transaction.date.minute}'),
            _buildDetailRow('Status', transaction.status),
            if (transaction.paymentMethod != null)
              _buildDetailRow('Payment Method', transaction.paymentMethod!),
            if (transaction.externalTransactionId != null)
              _buildDetailRow('Transaction ID', transaction.externalTransactionId!),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
            },
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  // Build detail row for transaction details
  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Expanded(
            child: Text(value),
          ),
        ],
      ),
    );
  }
}