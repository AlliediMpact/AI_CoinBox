// File: lib/providers/admin_provider.dart
import 'package:flutter/material.dart';
import '../models/user_role.dart';

class AdminProvider extends ChangeNotifier {
  // Example properties – adjust according to your requirements.
  int totalUsers = 0;
  int totalTransactions = 0;
  double totalCommissions = 0.0;
  UserRole currentUserRole = UserRole.admin;
  // List of users for audit logs, etc.
  List<dynamic> users = [];
  // Add additional properties and methods as needed.

  // Methods to update analytics data, load audit logs, etc.
  void updateAnalytics({required int usersCount, required int txCount, required double commissions}) {
    totalUsers = usersCount;
    totalTransactions = txCount;
    totalCommissions = commissions;
    notifyListeners();
  }
}
