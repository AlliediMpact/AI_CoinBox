import 'package:flutter/material.dart';

class KYCProvider extends ChangeNotifier {
  String _status = 'unverified'; // Initial status

  String get status => _status;

  void submitKYC(String documents) {
    // Logic to submit KYC documents
    // For now, we will simulate a successful submission
    _status = 'verified';
    notifyListeners();
  }

  bool isVerified() {
    return _status == 'verified';
  }
}
