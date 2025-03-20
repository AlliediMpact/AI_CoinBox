import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/referral_provider.dart';

class TopReferrersScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final referralProvider = Provider.of<ReferralProvider>(context);
    final topReferrers = referralProvider.topReferrers;

    return Scaffold(
      appBar: AppBar(
        title: Text('Top Referrers'),
      ),
      body: ListView.builder(
        itemCount: topReferrers.length,
        itemBuilder: (context, index) {
          final userId = topReferrers[index];
          final commission = referralProvider.referrals[userId] ?? 0.0;

          return ListTile(
            title: Text('User ID: $userId'),
            subtitle: Text('Commission: $commission'),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          referralProvider.awardBonuses();
        },
        child: Icon(Icons.card_giftcard),
        tooltip: 'Award Bonuses',
      ),
    );
  }
}
