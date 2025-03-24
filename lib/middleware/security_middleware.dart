import 'package:flutter/material.dart';
import '../services/security_service.dart';
import '../utils/error_handler.dart';

class SecurityMiddleware {
  // Check if session has timed out
  static Future<bool> checkSessionTimeout(BuildContext context) async {
    try {
      // Update last activity timestamp
      await SecurityService.updateLastActivity();
      
      // Check if session has timed out
      try {
        final hasTimedOut = await SecurityService.hasSessionTimedOut();
        if (hasTimedOut) {
          print('Session timed out.');
          _showSessionTimeoutDialog(context);
          return true;
        }
      } catch (e, stackTrace) {
        print('Error checking session timeout: $e');
        ErrorHandler.logError(e, stackTrace: stackTrace, hint: 'Session Timeout Error');
        return false;
      }
      
      return false;
    } catch (e, stackTrace) {
      ErrorHandler.logError(e, stackTrace: stackTrace);
      return false;
    }
  }
  
  // Show session timeout dialog
  static void _showSessionTimeoutDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        title: const Text('Session Timeout'),
        content: const Text(
          'Your session has timed out due to inactivity. Please sign in again to continue.',
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
            },
            child: const Text('Sign In'),
          ),
        ],
      ),
    );
  }
  
  // Check if biometric authentication is required
  static Future<bool> checkBiometricAuth(BuildContext context) async {
    try {
      final biometricEnabled = await SecurityService.isBiometricEnabled();
      if (!biometricEnabled) {
        return true; // Biometric auth not required
      }
      
      final authenticated = await SecurityService.authenticateWithBiometrics(context);
      if (!authenticated) {
        // Show authentication failed dialog
        _showAuthFailedDialog(context);
        return false;
      }
      
      return true;
    } catch (e, stackTrace) {
      ErrorHandler.logError(e, stackTrace: stackTrace);
      return false;
    }
  }
  
  // Show authentication failed dialog
  static void _showAuthFailedDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        title: const Text('Authentication Failed'),
        content: const Text(
          'Biometric authentication failed. Please try again or sign in with your password.',
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
            },
            child: const Text('Sign In'),
          ),
        ],
      ),
    );
  }
  
  // Check if PIN authentication is required
  static Future<bool> checkPinAuth(BuildContext context) async {
    try {
      final pinEnabled = await SecurityService.isPinEnabled();
      if (!pinEnabled) {
        return true; // PIN auth not required
      }
      
      // Show PIN input dialog
      final authenticated = await _showPinInputDialog(context);
      if (!authenticated) {
        // Show authentication failed dialog
        _showAuthFailedDialog(context);
        return false;
      }
      
      return true;
    } catch (e, stackTrace) {
      ErrorHandler.logError(e, stackTrace: stackTrace);
      return false;
    }
  }
  
  // Show PIN input dialog
  static Future<bool> _showPinInputDialog(BuildContext context) async {
    final pinController = TextEditingController();
    bool? result;
    
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        title: const Text('Enter PIN'),
        content: TextField(
          controller: pinController,
          keyboardType: TextInputType.number,
          obscureText: true,
          maxLength: 6,
          decoration: const InputDecoration(
            hintText: 'Enter your PIN',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              result = false;
            },
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              final pin = pinController.text.trim();
              final isValid = await SecurityService.verifyPin(pin);
              Navigator.of(ctx).pop();
              result = isValid;
            },
            child: const Text('Submit'),
          ),
        ],
      ),
    );
    
    return result ?? false;
  }
}