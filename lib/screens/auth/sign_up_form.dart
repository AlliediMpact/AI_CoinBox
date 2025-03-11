// File: lib/screens/auth/sign_up_form.dart

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../models/user_profile.dart';

class SignUpForm extends StatefulWidget {
  const SignUpForm({Key? key}) : super(key: key);

  @override
  _SignUpFormState createState() => _SignUpFormState();
}

class _SignUpFormState extends State<SignUpForm> {
  final _formKey = GlobalKey<FormState>();
  String email = '';
  String password = '';
  String membershipTier = 'basic'; // Default tier

  Future<void> _signUp() async {
    try {
      // Create a new user with FirebaseAuth.
      UserCredential cred = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: email, password: password);
      String uid = cred.user!.uid;

      // Create user profile in Firestore.
      await UserProfile.create(uid, {
        'email': email,
        'membershipTier': membershipTier,
        'loanLimit': 500,
        'investmentLimit': 5000,
      });
      // Navigate to dashboard or show a success message.
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Sign Up Error: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          // Email field.
          TextFormField(
            decoration: const InputDecoration(labelText: 'Email'),
            onSaved: (value) => email = value ?? '',
          ),
          // Password field.
          TextFormField(
            decoration: const InputDecoration(labelText: 'Password'),
            obscureText: true,
            onSaved: (value) => password = value ?? '',
          ),
          // Membership tier selection.
          DropdownButtonFormField<String>(
            value: membershipTier,
            items: ['basic', 'ambassador', 'vip', 'business']
                .map((tier) => DropdownMenuItem(value: tier, child: Text(tier)))
                .toList(),
            onChanged: (value) => setState(() => membershipTier = value ?? 'basic'),
            decoration: const InputDecoration(labelText: 'Membership Tier'),
          ),
          ElevatedButton(
            onPressed: () {
              _formKey.currentState!.save();
              _signUp();
            },
            child: const Text("Sign Up"),
          )
        ],
      ),
    );
  }
}
