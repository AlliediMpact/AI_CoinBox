import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ReferralLeaderboardScreen extends StatelessWidget {
  const ReferralLeaderboardScreen({Key? key}) : super(key: key);

  Future<List<Map<String, dynamic>>> _fetchLeaderboard() async {
    final snapshot = await FirebaseFirestore.instance
        .collection('users')
        .orderBy('totalReferrals', descending: true)
        .limit(10)
        .get();

    return snapshot.docs.map((doc) => doc.data()).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Referral Leaderboard'),
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _fetchLeaderboard(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final leaderboard = snapshot.data ?? [];

          if (leaderboard.isEmpty) {
            return const Center(child: Text('No referrals found.'));
          }

          return ListView.builder(
            itemCount: leaderboard.length,
            itemBuilder: (context, index) {
              final user = leaderboard[index];

              return Card(
                margin: const EdgeInsets.all(8.0),
                child: ListTile(
                  leading: CircleAvatar(
                    child: Text('${index + 1}'),
                  ),
                  title: Text(user['fullName'] ?? 'Unknown User'),
                  subtitle: Text('Total Referrals: ${user['totalReferrals'] ?? 0}'),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
