import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';
import '../models/wallet.dart';
import '../models/loan.dart';
import '../models/investment.dart';
import '../models/transaction.dart' as AppTransaction;
import '../models/referral.dart';
import '../constants/membership_tiers.dart';

class FinancialService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static final _uuid = Uuid();

  // Wallet Operations
  static Future<void> updateWalletBalance(
    String userId,
    double amount,
    bool isCommission,
  ) async {
    final walletRef = _firestore.collection('wallets').doc(userId);

    await _firestore.runTransaction((transaction) async {
      final walletDoc = await transaction.get(walletRef);
      if (!walletDoc.exists) {
        throw Exception('Wallet not found');
      }

      final wallet = Wallet.fromMap(walletDoc.data()!);
      wallet.balance += amount;
      transaction.update(walletRef, wallet.toMap());
    });
  }

  // Loan Operations
  static Future<String> requestLoan(String borrowerId, double amount) async {
    final loanId = _uuid.v4();
    final loan = Loan(
      id: loanId,
      borrowerId: borrowerId,
      amount: amount,
      repaymentAmount: amount * 1.25, // 25% interest
      requestDate: DateTime.now(),
      status: LoanStatus.pending,
    );

    await _firestore.collection('loans').doc(loanId).set(loan.toJson());
    return loanId;
  }

  // Investment Operations
  static Future<String> createInvestment(String investorId, double amount) async {
    final investmentId = _uuid.v4();
    final investment = Investment(
      id: investmentId,
      investorId: investorId,
      amount: amount,
      startDate: DateTime.now(),
      status: InvestmentStatus.pending,
    );

    await _firestore.collection('investments').doc(investmentId).set(investment.toJson());
    return investmentId;
  }

  // Transaction Recording
  static Future<void> recordTransaction(AppTransaction.Transaction transaction) async {
    await _firestore.collection('transactions').doc(transaction.id).set(transaction.toJson());
  }

  // Monthly Interest Distribution
  static Future<void> distributeMonthlyInterest(String investmentId) async {
    final investmentDoc = await _firestore.collection('investments').doc(investmentId).get();
    if (!investmentDoc.exists) throw Exception('Investment not found');

    final investment = Investment.fromJson(investmentDoc.data()!);
    final monthlyEarnings = investment.calculateMonthlyReturns();
    final investorShare = monthlyEarnings * 0.95; // 95% to investor
    final platformShare = monthlyEarnings * 0.05; // 5% to platform

    await Future.wait([
      updateWalletBalance(investment.investorId, investorShare, false),
      recordTransaction(AppTransaction.Transaction(
        id: _uuid.v4(),
        userId: investment.investorId,
        type: AppTransaction.TransactionType.investment,
        amount: investorShare,
        status: AppTransaction.TransactionStatus.completed,
        timestamp: DateTime.now(),
        metadata: {
          'investmentId': investmentId,
          'monthlyEarnings': monthlyEarnings,
          'platformShare': platformShare,
        },
      )),
      recordTransaction(AppTransaction.Transaction(
        id: _uuid.v4(),
        userId: 'platform', // Platform account
        type: AppTransaction.TransactionType.commission,
        amount: platformShare,
        status: AppTransaction.TransactionStatus.completed,
        timestamp: DateTime.now(),
        metadata: {
          'investmentId': investmentId,
          'monthlyEarnings': monthlyEarnings,
        },
      )),
    ]);

    // Update investment earnings history
    investment.earningsHistory.add(DateTime.now().toIso8601String());
    await _firestore.collection('investments').doc(investmentId).update({
      'earningsHistory': investment.earningsHistory,
      'totalReturns': investment.totalReturns + monthlyEarnings,
    });
  }

  // Commission Management
  static Future<void> distributeReferralCommission(
    String referrerId,
    String newUserId,
    MembershipTier tier,
  ) async {
    final commissionAmount = tier.securityFee * tier.commissionRate;
    await updateWalletBalance(referrerId, commissionAmount, true);
    
    await recordTransaction(AppTransaction.Transaction(
      id: _uuid.v4(),
      userId: referrerId,
      type: AppTransaction.TransactionType.commission,
      amount: commissionAmount,
      status: AppTransaction.TransactionStatus.completed,
      timestamp: DateTime.now(),
      metadata: {
        'referredUser': newUserId,
        'membershipTier': tier.name,
      },
    ));

    // Notify referrer
    print('Notification: You earned R${commissionAmount.toStringAsFixed(2)} from a referral.');
  }

  // Loan Processing
  static Future<void> processLoanRepayment(String loanId) async {
    final loanDoc = await _firestore.collection('loans').doc(loanId).get();
    if (!loanDoc.exists) throw Exception('Loan not found');

    final loan = Loan.fromJson(loanDoc.data()!);
    final repaymentAmount = loan.repaymentAmount;
    final investorShare = repaymentAmount * 0.95; // 95% to investor
    final borrowerShare = repaymentAmount * 0.05; // 5% to borrower's wallet

    await Future.wait([
      updateWalletBalance(loan.lenderId!, investorShare, false),
      updateWalletBalance(loan.borrowerId, borrowerShare, false),
      _firestore.collection('loans').doc(loanId).update({
        'status': LoanStatus.completed.toString(),
        'completionDate': DateTime.now().toIso8601String(),
      }),
    ]);
  }

  // Investment Processing
  static Future<void> processInvestmentReturn(String investmentId) async {
    final investmentDoc = await _firestore.collection('investments').doc(investmentId).get();
    if (!investmentDoc.exists) throw Exception('Investment not found');

    final investment = Investment.fromJson(investmentDoc.data()!);
    final monthlyReturn = investment.amount * 0.20; // 20% monthly return
    final investorShare = monthlyReturn * 0.95; // 95% to investor's bank
    final walletShare = monthlyReturn * 0.05; // 5% to investor's wallet

    await Future.wait([
      updateWalletBalance(investment.investorId, walletShare, false),
      recordTransaction(AppTransaction.Transaction(
        id: _uuid.v4(),
        userId: investment.investorId,
        type: AppTransaction.TransactionType.investment,
        amount: monthlyReturn,
        status: AppTransaction.TransactionStatus.completed,
        timestamp: DateTime.now(),
        metadata: {
          'investmentId': investmentId,
          'walletShare': walletShare,
          'bankShare': investorShare,
        },
      )),
    ]);
  }

  // Admin Fee Processing
  static Future<void> processAdminFee(String userId, MembershipTier tier) async {
    final adminFee = tier.adminFee;
    
    await recordTransaction(AppTransaction.Transaction(
      id: _uuid.v4(),
      userId: userId,
      type: AppTransaction.TransactionType.membership,
      amount: adminFee,
      status: AppTransaction.TransactionStatus.completed,
      timestamp: DateTime.now(),
      metadata: {
        'membershipTier': tier.name,
        'feeType': 'admin',
      },
    ));
  }

  // Transaction Fee Processing
  static Future<void> processTransactionFee(
    String userId,
    MembershipTier tier,
    AppTransaction.TransactionType type,
  ) async {
    final transactionFee = tier.transactionFee;
    
    await recordTransaction(AppTransaction.Transaction(
      id: _uuid.v4(),
      userId: userId,
      type: AppTransaction.TransactionType.membership,
      amount: transactionFee,
      status: AppTransaction.TransactionStatus.completed,
      timestamp: DateTime.now(),
      metadata: {
        'membershipTier': tier.name,
        'feeType': 'transaction',
        'transactionType': type.toString(),
      },
    ));
  }

  // Add these new methods to the FinancialService class

  static Future<String> generateReferralCode(String userId) async {
    final userDoc = await _firestore.collection('users').doc(userId).get();
    if (!userDoc.exists) throw Exception('User not found');

    String referralCode = '';
    bool isUnique = false;

    while (!isUnique) {
      // Generate 6 character alphanumeric code
      referralCode = (userId.substring(0, 3) + DateTime.now().millisecondsSinceEpoch.toString()).substring(0, 6).toUpperCase();
      
      final existing = await _firestore
          .collection('users')
          .where('referralCode', isEqualTo: referralCode)
          .get();
      
      if (existing.docs.isEmpty) isUnique = true;
    }

    await _firestore.collection('users').doc(userId).update({
      'referralCode': referralCode,
    });

    return referralCode;
  }

  static Future<void> processReferral(String referralCode, String newUserId) async {
    final referrerDoc = await _firestore
        .collection('users')
        .where('referralCode', isEqualTo: referralCode)
        .limit(1)
        .get();

    if (referrerDoc.docs.isEmpty) throw Exception('Invalid referral code');

    final referrerId = referrerDoc.docs.first.id;
    final referrerData = referrerDoc.docs.first.data();
    final membershipTier = MembershipTier.all.firstWhere(
      (tier) => tier.name == referrerData['membershipTier'],
    );

    final commissionAmount = membershipTier.securityFee * membershipTier.commissionRate;

    // Create referral record
    final referral = Referral(
      id: _uuid.v4(),
      referrerId: referrerId,
      referredUserId: newUserId,
      referralDate: DateTime.now(),
      commissionEarned: commissionAmount,
      membershipTier: membershipTier.name,
    );

    await Future.wait([
      // Save referral record
      _firestore.collection('referrals').doc(referral.id).set(referral.toJson()),
      
      // Update referrer's commission balance
      updateWalletBalance(referrerId, commissionAmount, true),
      
      // Record commission transaction
      recordTransaction(AppTransaction.Transaction(
        id: _uuid.v4(),
        userId: referrerId,
        type: AppTransaction.TransactionType.commission,
        amount: commissionAmount,
        status: AppTransaction.TransactionStatus.completed,
        timestamp: DateTime.now(),
        metadata: {
          'referralId': referral.id,
          'referredUser': newUserId,
        },
      )),
    ]);
  }

  // Add getReferralStats method
  static Future<Map<String, dynamic>> getReferralStats(String userId) async {
    final referrals = await _firestore
        .collection('referrals')
        .where('referrerId', isEqualTo: userId)
        .get();

    return {
      'totalReferrals': referrals.docs.length,
      'totalCommission': referrals.docs
          .map((doc) => doc.data()['commissionEarned'] as double)
          .fold(0.0, (prev, curr) => prev + curr),
      'activeReferrals': referrals.docs
          .where((doc) => doc.data()['isActive'] == true)
          .length,
    };
  }

  // Platform Fee Calculation
  static Future<void> processPlatformFee(String userId, double amount, AppTransaction.TransactionType type) async {
    final platformFee = amount * 0.05; // 5% platform fee
    await recordTransaction(AppTransaction.Transaction(
      id: _uuid.v4(),
      userId: 'platform', // Platform account
      type: type,
      amount: platformFee,
      status: AppTransaction.TransactionStatus.completed,
      timestamp: DateTime.now(),
      metadata: {
        'userId': userId,
        'originalAmount': amount,
      },
    ));
  }
}
