import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';
import '../constants/app_colors.dart';
import '../models/referral.dart';
import '../services/referral_service.dart';
import '../utils/error_handler.dart';
import '../widgets/custom_button.dart';

class ReferralsScreen extends StatefulWidget {
  const ReferralsScreen({Key? key}) : super(key: key);

  @override
  State<ReferralsScreen> createState() => _ReferralsScreenState();
}

class _ReferralsScreenState extends State<ReferralsScreen> {
  bool _isLoading = true;
  String _referralCode = '';
  List<Referral> _referrals = [];
  double _totalCommission = 0.0;
  double _commissionRate = 0.0;

  @override
  void initState() {
    super.initState();
    _loadReferralData();
  }

  // Load referral data from the service
  Future<void> _loadReferralData() async {
    try {
      setState(() {
        _isLoading = true;
      });

      // Get referral data from the service
      final referralData = await ReferralService.getReferralData();
      
      setState(() {
        _referralCode = referralData.referralCode;
        _referrals = referralData.referrals;
        _totalCommission = referralData.totalCommission;
        _commissionRate = referralData.commissionRate;
        _isLoading = false;
      });
    } catch (e, stackTrace) {
      ErrorHandler.logError(e, stackTrace: stackTrace);
      ErrorHandler.showErrorDialog(
        context, 
        'Failed to load referral data. Please try again.'
      );
      setState(() {
        _isLoading = false;
      });
    }
  }

  // Copy referral code to clipboard
  void _copyReferralCode() {
    Clipboard.setData(ClipboardData(text: _referralCode));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Referral code copied to clipboard!'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  // Share referral code
  void _shareReferralCode() {
    Share.share(
      'Join AI CoinBox using my referral code: $_referralCode and get started with P2P lending and investments!',
      subject: 'Join AI CoinBox',
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Referrals'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadReferralData,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Referral code card
                      Card(
                        elevation: 4,
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Your Referral Code',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 10),
                              Row(
                                children: [
                                  Expanded(
                                    child: Container(
                                      padding: const EdgeInsets.all(12),
                                      decoration: BoxDecoration(
                                        color: Colors.grey[200],
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: Text(
                                        _referralCode,
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.copy),
                                    onPressed: _copyReferralCode,
                                    tooltip: 'Copy to clipboard',
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              CustomButton(
                                text: 'Share Referral Code',
                                onPressed: _shareReferralCode,
                                icon: Icons.share,
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      
                      // Commission information
                      Card(
                        elevation: 4,
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Commission Information',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 10),
                              Text(
                                'Your Commission Rate: ${(_commissionRate * 100).toStringAsFixed(0)}%',
                                style: const TextStyle(fontSize: 16),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Total Commission Earned: R${_totalCommission.toStringAsFixed(2)}',
                                style: const TextStyle(fontSize: 16),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      
                      // Referrals list
                      const Text(
                        'Your Referrals',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 10),
                      _referrals.isEmpty
                          ? const Card(
                              child: Padding(
                                padding: EdgeInsets.all(16.0),
                                child: Text(
                                  'You haven\'t referred anyone yet. Share your referral code to start earning commissions!',
                                  style: TextStyle(fontSize: 16),
                                ),
                              ),
                            )
                          : ListView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: _referrals.length,
                              itemBuilder: (context, index) {
                                final referral = _referrals[index];
                                return Card(
                                  margin: const EdgeInsets.only(bottom: 8),
                                  child: ListTile(
                                    title: Text(referral.userName),
                                    subtitle: Text(
                                      'Joined: ${referral.joinDate}',
                                    ),
                                    trailing: Text(
                                      'R${referral.commission.toStringAsFixed(2)}',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.success,
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                    ],
                  ),
                ),
              ),
            ),
    );
  }
}