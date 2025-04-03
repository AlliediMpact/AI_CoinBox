import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class PaystackService {
  static const String _secretKey = 'YOUR_PAYSTACK_SECRET_KEY';
  static const String _publicKey = 'YOUR_PAYSTACK_PUBLIC_KEY';
  static const String _baseUrl = 'https://api.paystack.co';

  static Future<Map<String, dynamic>> initializeTransaction({
    required String email,
    required double amount,
    String? reference,
  }) async {
    final url = Uri.parse('$_baseUrl/transaction/initialize');
    try {
      final response = await http.post(
        url,
        headers: {
          'Authorization': 'Bearer $_secretKey',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'email': email,
          'amount': (amount * 100).round(), // Convert to lowest currency unit (cents)
          'currency': 'ZAR',
          'reference': reference,
          'callback_url': 'https://your-callback-url.com',
        }),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to initialize transaction: ${response.body}');
      }
    } catch (e) {
      // Log the error for debugging
      print('Error initializing transaction: $e');
      rethrow;
    }
  }

  static Future<Map<String, dynamic>> verifyTransaction(String reference) async {
    final url = Uri.parse('$_baseUrl/transaction/verify/$reference');
    final response = await http.get(
      url,
      headers: {
        'Authorization': 'Bearer $_secretKey',
      },
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to verify transaction: ${response.body}');
    }
  }
}
