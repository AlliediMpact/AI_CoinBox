// File: lib/screens/wallet_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/wallet_provider.dart';
import '../providers/transaction_provider.dart';
import '../widgets/custom_button.dart';
import '../utils/app_colors.dart';

class WalletScreen extends StatefulWidget {
  const WalletScreen({Key? key}) : super(key: key);

  @override
  _WalletScreenState createState() => _WalletScreenState();
}

class _WalletScreenState extends State<WalletScreen> {
  @override
  Widget build(BuildContext context) {
    final walletProvider = Provider.of<WalletProvider>(context);
    final transactionProvider = Provider.of<TransactionProvider>(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text("Wallet"),
      ),
      body: Column(
        children: [
          Text("Balance: ${walletProvider.balance}"),
          CustomButton(
            text: "Deposit",
            onPressed: () async {
              await walletProvider.deposit(100.0);
              await transactionProvider.refresh();
            },
            btnColor: AppColors.success, // using our new parameter name
          ),
          CustomButton(
            text: "Withdraw",
            onPressed: () async {
              try {
                await walletProvider.withdraw(50.0);
                await transactionProvider.refresh();
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("Withdrawal failed: $e")),
                );
              }
            },
            btnColor: AppColors.error,
          ),
        ],
      ),
    );
  }
}
