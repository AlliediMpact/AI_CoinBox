// File: lib/screens/admin/admin_dashboard.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../constants/app_colors.dart';
import '../../providers/admin_provider.dart'; // Ensure this file exists with required properties.
import '../../widgets/custom_navigation_drawer.dart';
// Uncomment if you decide to use an alternative chart package later.
// import '../../widgets/analytics_chart.dart';
import '../../widgets/audit_log_table.dart';

class AdminDashboard extends StatelessWidget {
  const AdminDashboard({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Access admin data using AdminProvider.
    final adminProvider = Provider.of<AdminProvider>(context);

    // RBAC: Only allow admin or superAdmin to access the dashboard.
    if (adminProvider.currentUserRole != AdminUserRole.admin &&
        adminProvider.currentUserRole != AdminUserRole.superAdmin) {
      return Scaffold(
        appBar: AppBar(
          title: const Text("Access Denied"),
          backgroundColor: AppColors.primaryBlue,
        ),
        body: const Center(
          child: Text("You do not have permission to access this page."),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("Admin Dashboard"),
        backgroundColor: AppColors.primaryBlue,
      ),
      drawer: const CustomNavigationDrawer(), // Use the custom navigation drawer.
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Analytics Cards Row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildAnalyticsCard("Total Users", adminProvider.totalUsers.toString()),
                _buildAnalyticsCard("Transactions", adminProvider.totalTransactions.toString()),
                _buildAnalyticsCard("Commissions", "R${adminProvider.totalCommissions.toStringAsFixed(2)}"),
              ],
            ),
            const SizedBox(height: 24),
            // Analytics Chart Section (commented out due to charts_flutter issues)
            /*
            const Text(
              "User Growth Over Time",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 300,
              child: AnalyticsChart([]), // Provide actual chart data if available.
            ),
            const SizedBox(height: 24),
            */
            // Audit Logs Section
            const Text(
              "Audit Logs",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
            ),
            const SizedBox(height: 16),
            // AuditLogTable is not const if its constructor is not marked const.
            AuditLogTable(),
            const SizedBox(height: 24),
            // Notification Management Section
            ElevatedButton.icon(
              onPressed: () {
                Navigator.pushNamed(context, '/compose_notification');
              },
              icon: const Icon(Icons.notifications_active),
              label: const Text("Compose Notification"),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryBlue,
              ),
            ),
            const SizedBox(height: 24),
            // System Settings Section
            ElevatedButton.icon(
              onPressed: () {
                Navigator.pushNamed(context, '/admin/settings');
              },
              icon: const Icon(Icons.settings),
              label: const Text("System Settings"),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryBlue,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Builds an analytics card displaying a title and a value.
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
}
