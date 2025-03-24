import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {
  static final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  static Future<void> initialize() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const InitializationSettings initializationSettings =
        InitializationSettings(android: initializationSettingsAndroid);

    await _notificationsPlugin.initialize(initializationSettings);
  }

  static Future<void> showNotification(String title, String body) async {
    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails('channel_id', 'channel_name',
            importance: Importance.high, priority: Priority.high);

    const NotificationDetails notificationDetails =
        NotificationDetails(android: androidDetails);

    await _notificationsPlugin.show(0, title, body, notificationDetails);
  }

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
