import 'package:cloud_firestore/cloud_firestore.dart';

class AdminService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  static Future<void> logAdminAction({
    required String adminId,
    required String action,
    required Map<String, dynamic> details,
  }) async {
    await _firestore.collection('admin_logs').add({
      'adminId': adminId,
      'action': action,
      'details': details,
      'timestamp': FieldValue.serverTimestamp(),
    });
  }
}
