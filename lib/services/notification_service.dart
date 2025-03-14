// File: lib/services/notification_service.dart

import 'package:firebase_messaging/firebase_messaging.dart';

class NotificationService {
  final FirebaseMessaging _messaging = FirebaseMessaging.instance;

  /// Initializes notification settings.
  Future<void> initialize() async {
    // WHY: Request permission and configure notifications.
    await _messaging.requestPermission();
    // Additional configuration (e.g., onMessage, onLaunch) can be added here.
  }
}
