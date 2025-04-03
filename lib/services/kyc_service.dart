import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io'; // Add this import

enum KYCStatus { pending, verified, rejected }

class KYCService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static final FirebaseStorage _storage = FirebaseStorage.instance;

  // Submit KYC documents
  static Future<void> submitKYC({
    required String userId,
    required String idDocumentPath,
    required String proofOfAddressPath,
  }) async {
    final idDocumentUrl = await _uploadFile(userId, idDocumentPath, 'id_document');
    final proofOfAddressUrl = await _uploadFile(userId, proofOfAddressPath, 'proof_of_address');

    await _firestore.collection('kyc').doc(userId).set({
      'userId': userId,
      'idDocumentUrl': idDocumentUrl,
      'proofOfAddressUrl': proofOfAddressUrl,
      'status': KYCStatus.pending.toString(),
      'submittedAt': FieldValue.serverTimestamp(),
    });
  }

  // Approve KYC
  static Future<void> approveKYC(String userId) async {
    await _firestore.collection('kyc').doc(userId).update({
      'status': KYCStatus.verified.toString(),
      'verifiedAt': FieldValue.serverTimestamp(),
    });

    await _firestore.collection('users').doc(userId).update({
      'kycStatus': KYCStatus.verified.toString(),
    });

    // Notify user
    print('Notification: KYC approved for user $userId');
  }

  // Reject KYC
  static Future<void> rejectKYC(String userId, String reason) async {
    await _firestore.collection('kyc').doc(userId).update({
      'status': KYCStatus.rejected.toString(),
      'rejectedAt': FieldValue.serverTimestamp(),
      'rejectionReason': reason,
    });

    await _firestore.collection('users').doc(userId).update({
      'kycStatus': KYCStatus.rejected.toString(),
    });

    // Notify user with reason
    print('Notification: KYC rejected for user $userId. Reason: $reason');
  }

  // Get KYC status
  static Future<KYCStatus> getKYCStatus(String userId) async {
    final kycDoc = await _firestore.collection('kyc').doc(userId).get();
    if (!kycDoc.exists) return KYCStatus.pending;

    final status = kycDoc.data()?['status'] as String;
    return KYCStatus.values.firstWhere((e) => e.toString() == status);
  }

  // Private helper to upload files
  static Future<String> _uploadFile(String userId, String filePath, String fileType) async {
    final ref = _storage.ref().child('kyc/$userId/$fileType');
    final uploadTask = ref.putFile(File(filePath));
    final snapshot = await uploadTask;
    return await snapshot.ref.getDownloadURL();
  }
}
