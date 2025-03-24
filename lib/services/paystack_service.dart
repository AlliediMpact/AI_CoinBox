import 'dart:convert';
import 'package:http/http.dart' as http;

class PaystackService {
  static const String _baseUrl = 'https://api.paystack.co';
  static const String _secretKey = 'sk_test_your_secret_key'; // Replace with your Paystack secret key

  /// Initialize a transaction
  static Future<Map<String, dynamic>> initializeTransaction({
    required String email,
    required int amount, // Amount in kobo
  }) async {
    final url = Uri.parse('$_baseUrl/transaction/initialize');
    final headers = {
      'Authorization': 'Bearer $_secretKey',
      'Content-Type': 'application/json',
    };
    final body = jsonEncode({
      'email': email,
      'amount': amount,
    });

    final response = await http.post(url, headers: headers, body: body);

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to initialize transaction: ${response.body}');
    }
  }

  /// Verify a transaction
  static Future<Map<String, dynamic>> verifyTransaction(String reference) async {
    final url = Uri.parse('$_baseUrl/transaction/verify/$reference');
    final headers = {
      'Authorization': 'Bearer $_secretKey',
    };

    final response = await http.get(url, headers: headers);

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to verify transaction: ${response.body}');
    }
  }
}
