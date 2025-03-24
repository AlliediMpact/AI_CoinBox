import 'package:flutter/material.dart';
import 'package:ai_coinbox/services/paystack_service.dart';
import 'package:url_launcher/url_launcher.dart';

class PaystackTestScreen extends StatelessWidget {
  const PaystackTestScreen({Key? key}) : super(key: key);

  Future<void> _handlePaystackPayment(BuildContext context) async {
    try {
      // Initialize the transaction
      final response = await PaystackService.initializeTransaction(
        email: 'test@example.com',
        amount: 5000, // Amount in kobo (e.g., 5000 kobo = 50 NGN)
      );

      final authorizationUrl = response['data']['authorization_url'];
      final reference = response['data']['reference'];

      // Open the payment page in a browser
      if (await canLaunch(authorizationUrl)) {
        await launch(authorizationUrl);

        // After payment, verify the transaction
        final verificationResponse = await PaystackService.verifyTransaction(reference);

        if (verificationResponse['data']['status'] == 'success') {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Payment successful. Reference: $reference')),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Payment verification failed.')),
          );
        }
      } else {
        throw Exception('Could not launch payment URL.');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Paystack Test')),
      body: Center(
        child: ElevatedButton(
          onPressed: () => _handlePaystackPayment(context),
          child: const Text('Test Paystack Payment'),
        ),
      ),
    );
  }
}
