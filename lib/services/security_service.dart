import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:local_auth/local_auth.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../utils/error_handler.dart';

class SecurityService {
  static final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();
  static final LocalAuthentication _localAuth = LocalAuthentication();
  static final FirebaseAuth _auth = FirebaseAuth.instance;
  
  static const String _biometricEnabledKey = 'biometricEnabled';
  static const String _pinEnabledKey = 'pinEnabled';
  static const String _pinKey = 'pin';
  static const String _lastActivityKey = 'lastActivity';
  static const String _sessionTimeoutKey = 'sessionTimeout';
  static const int _defaultSessionTimeout = 30; // 30 minutes
  
  // Check if biometric authentication is available
  static Future<bool> isBiometricAvailable() async {
    try {
      final canCheckBiometrics = await _localAuth.canCheckBiometrics;
      final isDeviceSupported = await _localAuth.isDeviceSupported();
      return canCheckBiometrics && isDeviceSupported;
    } catch (e, stackTrace) {
      ErrorHandler.logError(e, stackTrace: stackTrace);
      return false;
    }
  }
  
  // Get available biometric types
  static Future<List<BiometricType>> getAvailableBiometrics() async {
    try {
      return await _localAuth.getAvailableBiometrics();
    } catch (e, stackTrace) {
      ErrorHandler.logError(e, stackTrace: stackTrace);
      return [];
    }
  }
  
  // Authenticate with biometrics
  static Future<bool> authenticateWithBiometrics(BuildContext context) async {
    try {
      return await _localAuth.authenticate(
        localizedReason: 'Authenticate to access your account',
        options: const AuthenticationOptions(
          stickyAuth: true,
          biometricOnly: true,
        ),
      );
    } catch (e, stackTrace) {
      ErrorHandler.logError(e, stackTrace: stackTrace);
      ErrorHandler.showErrorSnackBar(
        context, 
        'Biometric authentication failed'
      );
      return false;
    }
  }
  
  // Check if biometric authentication is enabled
  static Future<bool> isBiometricEnabled() async {
    try {
      final value = await _secureStorage.read(key: _biometricEnabledKey);
      return value == 'true';
    } catch (e, stackTrace) {
      ErrorHandler.logError(e, stackTrace: stackTrace);
      return false;
    }
  }
  
  // Enable or disable biometric authentication
  static Future<void> setBiometricEnabled(bool enabled) async {
    try {
      await _secureStorage.write(
        key: _biometricEnabledKey, 
        value: enabled.toString(),
      );
    } catch (e, stackTrace) {
      ErrorHandler.logError(e, stackTrace: stackTrace);
      rethrow;
    }
  }
  
  // Check if PIN authentication is enabled
  static Future<bool> isPinEnabled() async {
    try {
      final value = await _secureStorage.read(key: _pinEnabledKey);
      return value == 'true';
    } catch (e, stackTrace) {
      ErrorHandler.logError(e, stackTrace: stackTrace);
      return false;
    }
  }
  
  // Enable or disable PIN authentication
  static Future<void> setPinEnabled(bool enabled) async {
    try {
      await _secureStorage.write(
        key: _pinEnabledKey, 
        value: enabled.toString(),
      );
    } catch (e, stackTrace) {
      ErrorHandler.logError(e, stackTrace: stackTrace);
      rethrow;
    }
  }
  
  // Set PIN
  static Future<void> setPin(String pin) async {
    try {
      await _secureStorage.write(key: _pinKey, value: pin);
    } catch (e, stackTrace) {
      ErrorHandler.logError(e, stackTrace: stackTrace);
      rethrow;
    }
  }
  
  // Verify PIN
  static Future<bool> verifyPin(String pin) async {
    try {
      final storedPin = await _secureStorage.read(key: _pinKey);
      return storedPin == pin;
    } catch (e, stackTrace) {
      ErrorHandler.logError(e, stackTrace: stackTrace);
      return false;
    }
  }
  
  // Update last activity timestamp
  static Future<void> updateLastActivity() async {
    try {
      final timestamp = DateTime.now().millisecondsSinceEpoch.toString();
      await _secureStorage.write(key: _lastActivityKey, value: timestamp);
    } catch (e, stackTrace) {
      ErrorHandler.logError(e, stackTrace: stackTrace);
    }
  }
  
  // Check if session has timed out
  static Future<bool> hasSessionTimedOut() async {
    try {
      final lastActivityStr = await _secureStorage.read(key: _lastActivityKey);
      final sessionTimeoutStr = await _secureStorage.read(key: _sessionTimeoutKey);
      
      if (lastActivityStr == null) {
        return false; // No last activity recorded
      }
      
      final lastActivity = int.parse(lastActivityStr);
      final sessionTimeout = sessionTimeoutStr != null 
          ? int.parse(sessionTimeoutStr) 
          : _defaultSessionTimeout;
      
      final currentTime = DateTime.now().millisecondsSinceEpoch;
      final elapsedMinutes = (currentTime - lastActivity) / (1000 * 60);
      
      return elapsedMinutes > sessionTimeout;
    } catch (e, stackTrace) {
      ErrorHandler.logError(e, stackTrace: stackTrace);
      return false;
    }
  }
  
  // Set session timeout in minutes
  static Future<void> setSessionTimeout(int minutes) async {
    try {
      await _secureStorage.write(key: _sessionTimeoutKey, value: minutes.toString());
    } catch (e, stackTrace) {
      ErrorHandler.logError(e, stackTrace: stackTrace);
    }
  }
  
  // Get current session timeout in minutes
  static Future<int> getSessionTimeout() async {
    try {
      final sessionTimeoutStr = await _secureStorage.read(key: _sessionTimeoutKey);
      return sessionTimeoutStr != null 
          ? int.parse(sessionTimeoutStr) 
          : _defaultSessionTimeout;
    } catch (e, stackTrace) {
      ErrorHandler.logError(e, stackTrace: stackTrace);
      return _defaultSessionTimeout;
    }
  }
  
  // Change password
  static Future<void> changePassword(String currentPassword, String newPassword) async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        throw Exception('User not authenticated');
      }
      
      // Get the user's email
      final email = user.email;
      if (email == null) {
        throw Exception('User email not available');
      }
      
      // Re-authenticate the user
      final credential = EmailAuthProvider.credential(
        email: email,
        password: currentPassword,
      );
      
      await user.reauthenticateWithCredential(credential);
     
     // Change the password
      await user.updatePassword(newPassword);
    } catch (e, stackTrace) {
      ErrorHandler.logError(e, stackTrace: stackTrace);
      rethrow;
    }
  }
  
  // Delete account
  static Future<void> deleteAccount(String password) async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        throw Exception('User not authenticated');
      }
      
      // Get the user's email
      final email = user.email;
      if (email == null) {
        throw Exception('User email not available');
      }
      
      // Re-authenticate the user
      final credential = EmailAuthProvider.credential(
        email: email,
        password: password,
      );
      
      await user.reauthenticateWithCredential(credential);
      
      // Delete the user account
      await user.delete();
      
      // Clear all security settings
      await clearSecuritySettings();
    } catch (e, stackTrace) {
      ErrorHandler.logError(e, stackTrace: stackTrace);
      rethrow;
    }
  }
  
  // Clear all security settings
  static Future<void> clearSecuritySettings() async {
    try {
      await _secureStorage.deleteAll();
    } catch (e, stackTrace) {
      ErrorHandler.logError(e, stackTrace: stackTrace);
      rethrow;
    }
  }
  
  // Encrypt sensitive data
  static String encryptData(String data) {
    // In a real app, you would use a proper encryption algorithm
    // For simplicity, we'll just use a basic encoding here
    return data; // Replace with actual encryption
  }
  
  // Decrypt sensitive data
  static String decryptData(String encryptedData) {
    // In a real app, you would use a proper decryption algorithm
    // For simplicity, we'll just return the data as is
    return encryptedData; // Replace with actual decryption
  }
  
  // Validate password strength
  static bool isPasswordStrong(String password) {
    // Check if password is at least 8 characters long
    if (password.length < 8) {
      return false;
    }
    
    // Check if password contains at least one uppercase letter
    if (!password.contains(RegExp(r'[A-Z]'))) {
      return false;
    }
    
    // Check if password contains at least one lowercase letter
    if (!password.contains(RegExp(r'[a-z]'))) {
      return false;
    }
    
    // Check if password contains at least one digit
    if (!password.contains(RegExp(r'[0-9]'))) {
      return false;
    }
    
    // Check if password contains at least one special character
    if (!password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'))) {
      return false;
    }
    
    return true;
  }
  
  // Get password strength message
  static String getPasswordStrengthMessage(String password) {
    if (password.isEmpty) {
      return 'Please enter a password';
    }
    
    if (password.length < 8) {
      return 'Password must be at least 8 characters long';
    }
    
    if (!password.contains(RegExp(r'[A-Z]'))) {
      return 'Password must contain at least one uppercase letter';
    }
    
    if (!password.contains(RegExp(r'[a-z]'))) {
      return 'Password must contain at least one lowercase letter';
    }
    
    if (!password.contains(RegExp(r'[0-9]'))) {
      return 'Password must contain at least one digit';
    }
    
    if (!password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'))) {
      return 'Password must contain at least one special character';
    }
    
    return 'Password is strong';
  }
  
  // Create a security activity log
  static Future<void> logSecurityActivity(String activity, {String? details}) async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        return;
      }
      
      // In a real app, you would log this to a secure database
      // For now, we'll just print it
      final timestamp = DateTime.now().toIso8601String();
      final userId = user.uid;
      final logEntry = {
        'timestamp': timestamp,
        'userId': userId,
        'activity': activity,
        'details': details,
      };
      
      debugPrint('Security Activity Log: $logEntry');
      
      // TODO: Log to Firestore or another secure storage
    } catch (e, stackTrace) {
      ErrorHandler.logError(e, stackTrace: stackTrace);
    }
  }
}