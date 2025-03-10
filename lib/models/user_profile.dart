import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/firebase_service.dart';

class UserProfile {
  final String uid;
  final String email;
  final String? name;
  final String? phone;
  final String membershipType;
  final DateTime createdAt;

  UserProfile({
    required this.uid,
    required this.email,
    this.name,
    this.phone,
    required this.membershipType,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'email': email,
      'name': name,
      'phone': phone,
      'membershipType': membershipType,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory UserProfile.fromMap(Map<String, dynamic> map) {
    return UserProfile(
      uid: map['uid'],
      email: map['email'],
      name: map['name'],
      phone: map['phone'],
      membershipType: map['membershipType'] ?? 'Basic',
      createdAt: DateTime.parse(map['createdAt']),
    );
  }

  static Stream<DocumentSnapshot> getUserStream(String uid) {
    return FirebaseService.firestore
        .collection('users')
        .doc(uid)
        .snapshots();
  }

  static Future<void> update(String uid, Map<String, dynamic> data) async {
    await FirebaseService.firestore.collection('users').doc(uid).update(data);
  }
  
  // Add the create function
    static Future<void> create(String uid, Map<String, dynamic> data) async {
    // Default values if not provided
    final profileData = {
      'uid': uid,
      'email': data['email'],
      'name': data['name'],
      'phone': '', 
      'membershipType': 'Basic', // Default value
      'createdAt': DateTime.now().toIso8601String(),
    };

    await FirebaseService.firestore.collection('users').doc(uid).set(profileData);
  }
}
