import 'package:flutter/material.dart';

class NotificationService {
  static void showNotification(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  static void notifyLoanApproval(BuildContext context) {
    showNotification(context, 'Your loan has been approved!');
  }

  static void notifyInvestmentUpdate(BuildContext context) {
    showNotification(context, 'Your investment has been updated!');
  }
}
