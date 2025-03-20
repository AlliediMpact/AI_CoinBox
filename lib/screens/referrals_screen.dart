// File: lib/screens/referrals_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../constants/app_colors.dart';
import '../providers/user_provider.dart';

class ReferralsScreen extends StatelessWidget {
  const ReferralsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Referrals'),
        backgroundColor: AppColors.primaryBlue,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Referral Code Card
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [AppColors.primaryBlue, AppColors.primaryPurple],
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Your Referral Code',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.white70,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      userProvider.referralCode.isNotEmpty
                          ? userProvider.referralCode
                          : 'N/A',
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      onPressed: () {
                        // TODO: Implement sharing functionality.
                      },
                      icon: const Icon(Icons.share, color: Colors.white),
                      label: const Text('Share Referral Code'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.success,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            // Referral Stats Card
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildReferralStat('Total Referrals', userProvider.totalReferrals),
                    _buildReferralStat('Commission Earned', 'R${userProvider.commissionBalance.toStringAsFixed(2)}'),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            // Leaderboard Header
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Top Referrers',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
            const SizedBox(height: 8),
            // Leaderboard List
            Expanded(
              child: ListView.builder(
                itemCount: userProvider.topReferrers.length,
                itemBuilder: (context, index) {
                  final referrer = userProvider.topReferrers[index];
                  return ListTile(
                    leading: CircleAvatar(
                      backgroundImage: referrer.profileImageUrl.isNotEmpty
                          ? NetworkImage(referrer.profileImageUrl)
                          : const AssetImage('assets/images/user_placeholder.png') as ImageProvider,
                    ),
                    title: Text(referrer.fullName),
                    subtitle: Text('Referrals: ${referrer.referralCount}'),
                    trailing: Text(
                      'R${referrer.commissionEarned.toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: AppColors.success,
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReferralStat(String title, dynamic value) {
    return Column(
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 14, color: AppColors.textSecondary),
        ),
        const SizedBox(height: 4),
        Text(
          '$value',
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.primaryBlue),
        ),
      ],
    );
  }
}
