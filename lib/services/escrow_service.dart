import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';
import '../models/transaction.dart';

enum EscrowStatus { pending, locked, released, refunded }

class EscrowService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static final _uuid = Uuid();

  static Future<String> createEscrow({
    required String payerId,
    required String receiverId,
    required double amount,
    required TransactionType type,
    Map<String, dynamic>? metadata,
  }) async {
    final escrowId = _uuid.v4();
    
    await _firestore.collection('escrow').doc(escrowId).set({
      'id': escrowId,
      'payerId': payerId,
      'receiverId': receiverId,
      'amount': amount,
      'status': EscrowStatus.pending.toString(),
      'type': type.toString(),
      'createdAt': FieldValue.serverTimestamp(),
      'metadata': metadata,
    });

    return escrowId;
  }

  static Future<void> lockFunds(String escrowId) async {
    await _firestore.collection('escrow').doc(escrowId).update({
      'status': EscrowStatus.locked.toString(),
      'lockedAt': FieldValue.serverTimestamp(),
    });

    // Notify payer and receiver
    final escrowDoc = await _firestore.collection('escrow').doc(escrowId).get();
    final escrowData = escrowDoc.data();
    if (escrowData != null) {
      final payerId = escrowData['payerId'];
      final receiverId = escrowData['receiverId'];
      // Send notifications (implementation depends on your notification system)
      print('Notification: Funds locked for escrow $escrowId');
    }
  }

  static Future<void> releaseFunds(String escrowId) async {
    final escrowDoc = await _firestore.collection('escrow').doc(escrowId).get();
    if (!escrowDoc.exists) throw Exception('Escrow not found');

    await _firestore.runTransaction((transaction) async {
      transaction.update(escrowDoc.reference, {
        'status': EscrowStatus.released.toString(),
        'releasedAt': FieldValue.serverTimestamp(),
      });
    });

    // Log transaction
    final escrowData = escrowDoc.data();
    if (escrowData != null) {
      await FinancialService.recordTransaction(Transaction(
        id: _uuid.v4(),
        userId: escrowData['receiverId'],
        type: TransactionType.deposit,
        amount: escrowData['amount'],
        status: TransactionStatus.completed,
        timestamp: DateTime.now(),
        metadata: {
          'escrowId': escrowId,
        },
      ));
    }
  }

  static Future<void> refundFunds(String escrowId) async {
    await _firestore.collection('escrow').doc(escrowId).update({
      'status': EscrowStatus.refunded.toString(),
      'refundedAt': FieldValue.serverTimestamp(),
    });

    // Notify payer
    final escrowDoc = await _firestore.collection('escrow').doc(escrowId).get();
    final escrowData = escrowDoc.data();
    if (escrowData != null) {
      final payerId = escrowData['payerId'];
      print('Notification: Escrow funds refunded for escrow $escrowId.');
    }
  }
}
