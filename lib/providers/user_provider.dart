import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class UserProvider with ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  String _userId = '';
  String _fullName = '';
  String _email = '';
  String _phone = '';
  String _membershipType = '';
  String _referralCode = '';
  String _profileImageUrl = '';
  bool _isLoading = false;
  User? _user;
  
  // Getters
  String get userId => _userId;
  String get fullName => _fullName;
  String get email => _email;
  String get phone => _phone;
  String get membershipType => _membershipType;
  String get referralCode => _referralCode;
  String get profileImageUrl => _profileImageUrl;
  bool get isLoading => _isLoading;
  User? get user => _user;
  
  // Set Firebase user
  void setUser(User? user) {
    _user = user;
    if (user != null) {
      _userId = user.uid;
      _email = user.email ?? '';
      loadUserData();
    }
    notifyListeners();
  }
  
  // Set profile data from Firestore document
  void setProfileData(Map<String, dynamic> data) {
    _fullName = data['fullName'] ?? '';
    _phone = data['phone'] ?? '';
    _membershipType = data['membershipType'] ?? '';
    _referralCode = data['referralCode'] ?? '';
    _profileImageUrl = data['profileImageUrl'] ?? '';
    notifyListeners();
  }
  
  // Update user ID and load data
  void update(String userId) {
    if (userId.isNotEmpty && userId != _userId) {
      _userId = userId;
      loadUserData();
    }
  }
  
  // Load user data from Firestore
  Future<void> loadUserData() async {
    if (_userId.isEmpty) return;
    
    _setLoading(true);
    
    try {
      final DocumentSnapshot userDoc = 
          await _firestore.collection('users').doc(_userId).get();
      
      if (userDoc.exists) {
        final userData = userDoc.data() as Map<String, dynamic>;
        setProfileData(userData);
      }
    } catch (e) {
      print('Error loading user data: $e');
    } finally {
      _setLoading(false);
    }
  }
  
  // Update user profile
  Future<bool> updateProfile({
    String? fullName,
    String? phone,
    String? profileImageUrl,
  }) async {
    if (_userId.isEmpty) return false;
    
    _setLoading(true);
    
    try {
      final Map<String, dynamic> updateData = {};
      
      if (fullName != null) updateData['fullName'] = fullName;
      if (phone != null) updateData['phone'] = phone;
      if (profileImageUrl != null) updateData['profileImageUrl'] = profileImageUrl;
      
      await _firestore.collection('users').doc(_userId).update(updateData);
      
      // Update local data
      if (fullName != null) _fullName = fullName;
      if (phone != null) _phone = phone;
      if (profileImageUrl != null) _profileImageUrl = profileImageUrl;
      
      _setLoading(false);
      return true;
    } catch (e) {
      print('Error updating profile: $e');
      _setLoading(false);
      return false;
    }
  }
  
  // Set loading state
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }
}