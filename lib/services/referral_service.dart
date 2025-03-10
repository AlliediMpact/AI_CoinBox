import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/referral.dart';
import '../utils/error_handler.dart';

class ReferralService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static final FirebaseAuth _auth = FirebaseAuth.instance;

  // Get the current user's referral data
  static Future<ReferralData> getReferralData() async {
    try {
      final userId = _auth.currentUser?.uid;
      if (userId == null) {
        throw Exception('User not authenticated');
      }

      // Get user document to retrieve membership plan and referral code
      final userDoc = await _firestore.collection('users').doc(userId).get();
      if (!userDoc.exists) {
        throw Exception('User document not found');
      }

      final userData = userDoc.data() as Map<String, dynamic>;
      final membershipPlan = userData['membershipPlan'] ?? 'basic';
      final referralCode = userData['referralCode'] ?? '';

      // Determine commission rate based on membership plan
      double commissionRate = 0.01; // Default to 1%
      switch (membershipPlan) {
        case 'basic':
          commissionRate = 0.01; // 1%
          break;
        case 'ambassador':
          commissionRate = 0.02; // 2%
          break;
        case 'vip':
          commissionRate = 0.03; // 3%
          break;
        case 'business':
          commissionRate = 0.05; // 5%
          break;
      }

      // Get referrals where this user is the referrer
      final referralsSnapshot = await _firestore
          .collection('referrals')
          .where('referrerId', isEqualTo: userId)
          .get();

      final referrals = referralsSnapshot.docs
          .map((doc) => Referral.fromMap(doc.id, doc.data()))
          .toList();

      // Calculate total commission
      double totalCommission = 0;
      for (var referral in referrals) {
        totalCommission += referral.commission;
      }

      return ReferralData(
        referralCode: referralCode,
        referrals: referrals,
        totalCommission: totalCommission,
        commissionRate: commissionRate,
      );
    } catch (e, stackTrace) {
      ErrorHandler.logError(e, stackTrace: stackTrace);
      rethrow;
    }
  }

  // Generate a unique referral code for a new user
  static Future<String> generateReferralCode(String userId) async {
    try {
      // Generate a code based on user ID and timestamp
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final baseCode = userId.substring(0, 5) + timestamp.toString().substring(timestamp.toString().length - 5);
      
      // Convert to uppercase and add hyphens for readability
      final formattedCode = baseCode.toUpperCase().replaceAllMapped(
        RegExp(r'.{4}'),
        (match) => '${match.group(0)}-',
      );
      
      // Remove trailing hyphen if present
      return formattedCode.endsWith('-')
          ? formattedCode.substring(0, formattedCode.length - 1)
          : formattedCode;
    } catch (e, stackTrace) {
      ErrorHandler.logError(e, stackTrace: stackTrace);
      rethrow;
    }
  }

  // Process a new referral when a user signs up with a referral code
  static Future<void> processReferral(String referralCode, String newUserId, String newUserName) async {
    try {
      // Find the referrer based on the referral code
      final referrerQuery = await _firestore
          .collection('users')
          .where('referralCode', isEqualTo: referralCode)
          .limit(1)
          .get();

      if (referrerQuery.docs.isEmpty) {
        throw Exception('Invalid referral code');
      }

      final referrerDoc = referrerQuery.docs.first;
      final referrerId = referrerDoc.id;
      final referrerData = referrerDoc.data();
      final membershipPlan = referrerData['membershipPlan'] ?? 'basic';

      // Determine commission rate based on membership plan
      double commissionRate = 0.01; // Default to 1%
      switch (membershipPlan) {
        case 'basic':
          commissionRate = 0.01; // 1%
          break;
        case 'ambassador':
          commissionRate = 0.02; // 2%
          break;
        case 'vip':
          commissionRate = 0.03; // 3%
          break;
        case 'business':
          commissionRate = 0.05; // 5%
          break;
      }

      // Create a new referral record
      await _firestore.collection('referrals').add({
        'userId': newUserId,
        'userName': newUserName,
        'referrerId': referrerId,
        'referralCode': referralCode,
        'commission': 0.0, // Initial commission is 0
        'joinDate': DateTime.now().toIso8601String(),
      });

      // Update the user document to store who referred them
      await _firestore.collection('users').doc(newUserId).update({
        'referredBy': referrerId,
        'referralCode': referralCode,
      });
    } catch (e, stackTrace) {
      ErrorHandler.logError(e, stackTrace: stackTrace);
      rethrow;
    }
  }

  // Update commission when a referred user makes a transaction
  static Future<void> updateCommission(String userId, double transactionAmount) async {
    try {
      // Get the user to find who referred them
      final userDoc = await _firestore.collection('users').doc(userId).get();
      if (!userDoc.exists) {
        throw Exception('User document not found');
      }

      final userData = userDoc.data() as Map<String, dynamic>;
      final referredBy = userData['referredBy'];
      final referralCode = userData['referralCode'];

      // If the user wasn't referred, there's no commission to update
      if (referredBy == null || referralCode == null) {
        return;
      }

      // Get the referrer to determine their commission rate
      final referrerDoc = await _firestore.collection('users').doc(referredBy).get();
      if (!referrerDoc.exists) {
        throw Exception('Referrer document not found');
      }

      final referrerData = referrerDoc.data() as Map<String, dynamic>;
      final membershipPlan = referrerData['membershipPlan'] ?? 'basic';

      // Determine commission rate based on membership plan
      double commissionRate = 0.01; // Default to 1%
      switch (membershipPlan) {
        case 'basic':
          commissionRate = 0.01; // 1%
          break;
        case 'ambassador':
          commissionRate = 0.02; // 2%
          break;
        case 'vip':
          commissionRate = 0.03; // 3%
          break;
        case 'business':
          commissionRate = 0.05; // 5%
          break;
      }

      // Calculate commission amount
      final commissionAmount = transactionAmount * commissionRate;

      // Find the referral record
      final referralQuery = await _firestore
          .collection('referrals')
          .where('userId', isEqualTo: userId)
          .where('referrerId', isEqualTo: referredBy)
          .limit(1)
          .get();

      if (referralQuery.docs.isEmpty) {
        throw Exception('Referral record not found');
      }

      final referralDoc = referralQuery.docs.first;
      final currentCommission = (referralDoc.data()['commission'] ?? 0.0).toDouble();

      // Update the referral record with the new commission
      await _firestore.collection('referrals').doc(referralDoc.id).update({
        'commission': currentCommission + commissionAmount,
      });

      // Update the referrer's wallet with the commission
      final referrerWalletDoc = await _firestore.collection('wallets').doc(referredBy).get();
      if (referrerWalletDoc.exists) {
        final currentBalance = (referrerWalletDoc.data()?['balance'] ?? 0.0).toDouble();
        await _firestore.collection('wallets').doc(referredBy).update({
          'balance': currentBalance + commissionAmount,
        });

        // Add a transaction record for the commission
        await _firestore.collection('transactions').add({
          'userId': referredBy,
          'amount': commissionAmount,
          'type': 'commission',
          'description': 'Referral commission',
          'date': DateTime.now().toIso8601String(),
          'status': 'completed',
        });
      }
    } catch (e, stackTrace) {
      ErrorHandler.logError(e, stackTrace: stackTrace);
      rethrow;
    }
  }

  // Check if a referral code is valid
  static Future<bool> isReferralCodeValid(String referralCode) async {
    try {
      final referrerQuery = await _firestore
          .collection('users')
          .where('referralCode', isEqualTo: referralCode)
          .limit(1)
          .get();

      return referrerQuery.docs.isNotEmpty;
    } catch (e, stackTrace) {
      ErrorHandler.logError(e, stackTrace: stackTrace);
      return false;
    }
  }
}