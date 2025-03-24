import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ai_coinbox/providers/membership_provider.dart';

class DashboardScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Replace hardcoded values with dynamic data
    final membershipProvider = Provider.of<MembershipProvider>(context);
    final membershipTier = membershipProvider.currentTier.name;
    final loanLimit = membershipProvider.currentTier.loanLimit;
    final investmentLimit = membershipProvider.currentTier.investmentLimit;

    return Scaffold(
      appBar: AppBar(title: Text('Dashboard')),
      body: Column(
        children: [
          // Membership Details
          Card(
            child: ListTile(
              title: Text('Membership Tier: $membershipTier'),
              subtitle: Text('Loan Limit: R$loanLimit | Investment Limit: R$investmentLimit'),
            ),
          ),
          // Referral Statistics
          Card(
            child: ListTile(
              title: Text('Total Referrals: 10'), // Replace with dynamic data
              subtitle: Text('Total Commission Earned: R300'), // Replace with dynamic data
            ),
          ),
          // Transaction History
          Expanded(
            child: ListView.builder(
              itemCount: 10, // Replace with actual transaction count
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text('Transaction $index'),
                  subtitle: Text('Details of transaction $index'),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
