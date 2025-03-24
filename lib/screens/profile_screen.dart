import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import '../providers/user_provider.dart';
import '../services/firebase_service.dart';
import '../constants/app_colors.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  String _fullName = '';
  String _email = '';
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadProfileData();
  }

  Future<void> _loadProfileData() async {
    try {
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      setState(() {
        _fullName = userProvider.fullName;
        _email = userProvider.email;
      });
    } catch (e) {
      print('Error loading profile data: $e');
      // Handle the error
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error loading profile data: ${e.toString()}")),
      );
    }
  }

  Future<void> _updateProfile() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });
      try {
        final user = FirebaseService.auth.currentUser;
        if (user != null) {
          await FirebaseService.firestore.collection('users').doc(user.uid).update({
            'fullName': _fullName,
            'email': _email,
          });
          // Update user provider
          final userProvider = Provider.of<UserProvider>(context, listen: false);
          userProvider.setProfileData({
            'fullName': _fullName,
            'email': _email,
          });
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Profile updated successfully!')),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error updating profile: $e')),
        );
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                decoration: const InputDecoration(labelText: 'Full Name'),
                initialValue: _fullName,
                validator: (value) => (value == null || value.isEmpty) ? 'Required' : null,
                onChanged: (value) => _fullName = value,
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Email'),
                initialValue: _email,
                validator: (value) => (value == null || !value.contains('@')) ? 'Invalid email' : null,
                onChanged: (value) => _email = value,
              ),
              const SizedBox(height: 20),
              _isLoading
                  ? const CircularProgressIndicator()
                  : ElevatedButton(
                      onPressed: _updateProfile,
                      child: const Text('Update Profile'),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
