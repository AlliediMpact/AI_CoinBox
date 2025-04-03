import 'package:cloud_firestore/cloud_firestore.dart';

class Referral {
  final String id;
  final String referrerId;
  final String referredUserId;
  final DateTime referralDate;
  final double commissionEarned;
  final bool isActive;
  final String membershipTier;

  Referral({
    required this.id,
    required this.referrerId,
    required this.referredUserId,
    required this.referralDate,
    required this.commissionEarned,
    this.isActive = true,
    required this.membershipTier,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'referrerId': referrerId,
    'referredUserId': referredUserId,
    'referralDate': Timestamp.fromDate(referralDate),
    'commissionEarned': commissionEarned,
    'isActive': isActive,
    'membershipTier': membershipTier,
  };

  factory Referral.fromJson(Map<String, dynamic> json) => Referral(
    id: json['id'],
    referrerId: json['referrerId'],
    referredUserId: json['referredUserId'],
    referralDate: (json['referralDate'] as Timestamp).toDate(),
    commissionEarned: json['commissionEarned'],
    isActive: json['isActive'],
    membershipTier: json['membershipTier'],
  );

  factory Referral.fromMap(String id, Map<String, dynamic> map) {
    return Referral(
      id: id,
      referrerId: map['referrerId'],
      referredUserId: map['referredUserId'],
      referralDate: (map['referralDate'] as Timestamp).toDate(),
      commissionEarned: map['commissionEarned'],
      isActive: map['isActive'],
      membershipTier: map['membershipTier'],
    );
  }

  static Future<void> deactivateReferral(String referredUserId) async {
    final referralDocs = await FirebaseFirestore.instance
        .collection('referrals')
        .where('referredUserId', isEqualTo: referredUserId)
        .get();

    for (final doc in referralDocs.docs) {
      await doc.reference.update({'isActive': false});
    }
  }
}

// Class to hold referral data for the user
class ReferralData {
  final String referralCode;
  final List<Referral> referrals;
  final double totalCommission;
  final double commissionRate;

  ReferralData({
    required this.referralCode,
    required this.referrals,
    required this.totalCommission,
    required this.commissionRate,
  });
}