class MembershipTier {
  final String name;
  final double securityFee;
  final double refundableAmount;
  final double loanLimit;
  final double investmentLimit;
  final double commissionRate;
  final double transactionFee;
  final double adminFee;

  const MembershipTier({
    required this.name,
    required this.securityFee,
    required this.refundableAmount,
    required this.loanLimit,
    required this.investmentLimit,
    required this.commissionRate,
    required this.transactionFee,
    required this.adminFee,
  });

  static const basic = MembershipTier(
    name: 'basic',
    securityFee: 550,
    refundableAmount: 500,
    loanLimit: 500,
    investmentLimit: 5000,
    commissionRate: 0.01,
    transactionFee: 10,
    adminFee: 50,
  );

  static const ambassador = MembershipTier(
    name: 'ambassador',
    securityFee: 1100,
    refundableAmount: 1000,
    loanLimit: 1000,
    investmentLimit: 10000,
    commissionRate: 0.02,
    transactionFee: 10,
    adminFee: 100,
  );

  static const vip = MembershipTier(
    name: 'vip',
    securityFee: 5500,
    refundableAmount: 5000,
    loanLimit: 5000,
    investmentLimit: 50000,
    commissionRate: 0.03,
    transactionFee: 10,
    adminFee: 500,
  );

  static const business = MembershipTier(
    name: 'business',
    securityFee: 11000,
    refundableAmount: 10000,
    loanLimit: 10000,
    investmentLimit: 100000,
    commissionRate: 0.05,
    transactionFee: 10,
    adminFee: 1000,
  );

  static const List<MembershipTier> all = [basic, ambassador, vip, business];
}
