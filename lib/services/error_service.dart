import 'package:cloud_firestore/cloud_firestore.dart';

class ErrorService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Log an error to Firestore
  static Future<void> logError(String error, StackTrace? stackTrace) async {
    try {
      await _firestore.collection('error_logs').add({
        'error': error,
        'stackTrace': stackTrace?.toString(),
        'timestamp': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('Failed to log error: $e');
    }
  }
}
