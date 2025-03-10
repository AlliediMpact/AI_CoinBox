class Referral {
  final String id;
  final String userId;
  final String userName;
  final String referrerId;
  final String referralCode;
  final double commission;
  final String joinDate;

  Referral({
    required this.id,
    required this.userId,
    required this.userName,
    required this.referrerId,
    required this.referralCode,
    required this.commission,
    required this.joinDate,
  });

  // Create a Referral from a map (e.g., from Firestore)
  factory Referral.fromMap(String id, Map<String, dynamic> data) {
    return Referral(
      id: id,
      userId: data['userId'] ?? '',
      userName: data['userName'] ?? '',
      referrerId: data['referrerId'] ?? '',
      referralCode: data['referralCode'] ?? '',
      commission: (data['commission'] ?? 0.0).toDouble(),
      joinDate: data['joinDate'] ?? '',
    );
  }

  // Convert a Referral to a map (e.g., for Firestore)
  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'userName': userName,
      'referrerId': referrerId,
      'referralCode': referralCode,
      'commission': commission,
      'joinDate': joinDate,
    };
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