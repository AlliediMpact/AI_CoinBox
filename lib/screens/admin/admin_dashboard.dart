// File: lib/screens/admin/admin_dashboard.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../constants/app_colors.dart';
import '../../providers/admin_provider.dart'; // Assume an AdminProvider managing admin data
import '../../widgets/navigation_drawer.dart';

class AdminDashboard extends StatelessWidget {
  const AdminDashboard({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Access admin data via provider (users, transactions, etc.)
    final adminProvider = Provider.of<AdminProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
        backgroundColor: AppColors.primaryBlue,
      ),
      drawer: const NavigationDrawer(), // Reuse our navigation drawer or a custom admin drawer
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Quick Analytics Cards
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildAnalyticsCard('Total Users', adminProvider.totalUsers.toString()),
                _buildAnalyticsCard('Transactions', adminProvider.totalTransactions.toString()),
                _buildAnalyticsCard('Total Commissions', 'R${adminProvider.totalCommissions.toStringAsFixed(2)}'),
              ],
            ),
            const SizedBox(height: 24),
            // Section for User Management
            const Text(
              'User Management',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
            ),
            const SizedBox(height: 16),
            _buildUserTable(adminProvider),
          ],
        ),
      ),
    );
  }

  Widget _buildAnalyticsCard(String title, String value) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        width: 100,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [AppColors.primaryBlue, AppColors.primaryPurple],
          ),
        ),
        child: Column(
          children: [
            Text(
              title,
              style: const TextStyle(fontSize: 14, color: Colors.white70),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  // Example user management table (simplified)
  Widget _buildUserTable(AdminProvider adminProvider) {
    final users = adminProvider.users;
    if (users.isEmpty) {
      return const Center(child: Text('No user data available.'));
    }

    return DataTable(
      columns: const [
        DataColumn(label: Text('User')),
        DataColumn(label: Text('Email')),
        DataColumn(label: Text('Status')),
        DataColumn(label: Text('Actions')),
      ],
      rows: users.map((user) {
        return DataRow(
          cells: [
            DataCell(Text(user.fullName)),
            DataCell(Text(user.email)),
            DataCell(Text(user.isVerified ? 'Verified' : 'Pending')),
            DataCell(Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.visibility),
                  onPressed: () {
                    // View user details
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.block, color: Colors.red),
                  onPressed: () {
                    // Disable user or mark as fraudulent
                  },
                ),
              ],
            )),
          ],
        );
      }).toList(),
    );
  }
}
