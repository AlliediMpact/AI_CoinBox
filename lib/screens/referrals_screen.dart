// File: lib/screens/referrals_screen.dart

import 'package:flutter/material.dart';

class ReferralsScreen extends StatelessWidget {
  const ReferralsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Referrals"),
      ),
      body: Center(
        child: IconButton(
          icon: const Icon(Icons.share),
          onPressed: () {
            // Handle referral sharing logic
          },
        ),
      ),
    );
  }
}
