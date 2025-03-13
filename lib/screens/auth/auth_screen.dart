// File: lib/screens/auth/auth_screen.dart

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import '../../constants/app_colors.dart';
import '../../services/firebase_service.dart';
import '../../providers/user_provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'user_role.dart';

enum AuthMode { signIn, signUp, forgotPassword }

class AuthScreen extends StatefulWidget {
  const AuthScreen({Key? key}) : super(key: key);

  @override
  _AuthScreenState createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen>
    with SingleTickerProviderStateMixin {
  AuthMode _authMode = AuthMode.signIn;
  late AnimationController _controller;
  late Animation<double> _flipAnimation;
  final _formKey = GlobalKey<FormState>();

  // Form fields
  String _email = '';
  String _password = '';
  String _fullName = '';
  String _phone = '';
  String _referralCode = '';
  String _membershipTier = 'basic';

  @override
  void initState() {
    super.initState();
    // Initialize the animation controller for the flip effect
    _controller = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _flipAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  /// Switch authentication mode with a flip animation.
  void _switchAuthMode(AuthMode mode) {
    if (_authMode != mode) {
      setState(() {
        _authMode = mode;
      });
      _controller.forward(from: 0);
    }
  }

  /// Submit the form and perform authentication.
  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    _formKey.currentState!.save();

    try {
      if (_authMode == AuthMode.signIn) {
        // Sign in logic with Firebase
        UserCredential userCredential = await FirebaseService.auth
            .signInWithEmailAndPassword(email: _email, password: _password);
        // Update user provider and navigate to home
        Provider.of<UserProvider>(context, listen: false)
            .setUser(userCredential.user);
        Navigator.pushReplacementNamed(context, '/home');
      } else if (_authMode == AuthMode.signUp) {
        // Sign up logic with Firebase
        UserCredential userCredential = await FirebaseService.auth
            .createUserWithEmailAndPassword(email: _email, password: _password);
        String uid = userCredential.user!.uid;
        // Create user profile in Firestore with additional details
        await FirebaseService.firestore.collection('users').doc(uid).set({
          'fullName': _fullName,
          'email': _email,
          'phone': _phone,
          'referralCode': _referralCode,
          'membershipTier': _membershipTier,
          'loanLimit': _membershipTier == 'basic'
              ? 500
              : _membershipTier == 'ambassador'
                  ? 1000
                  : _membershipTier == 'business'
                      ? 10000
                      : 5000,
          'investmentLimit': _membershipTier == 'basic'
              ? 5000
              : _membershipTier == 'ambassador'
                  ? 10000
                  : _membershipTier == 'business'
                      ? 100000
                      : 50000,
        });
        Provider.of<UserProvider>(context, listen: false).setUser(userCredential.user);
        Navigator.pushReplacementNamed(context, '/home');
      } else if (_authMode == AuthMode.forgotPassword) {
        // Forgot password logic
        await FirebaseService.auth.sendPasswordResetEmail(email: _email);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Password reset email sent.")),
        );
        _switchAuthMode(AuthMode.signIn);
      }
    } catch (error) {
      // Detailed error feedback for the user
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Authentication error: ${error.toString()}")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 600;
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: AnimatedBuilder(
            animation: _flipAnimation,
            builder: (context, child) {
              final angle = _flipAnimation.value * 3.1416;
              return Transform(
                transform: Matrix4.rotationY(angle),
                alignment: Alignment.center,
                child: Container(
                  width: isMobile ? double.infinity : 500,
                  padding: const EdgeInsets.all(16.0),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.black26,
                        blurRadius: 8,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: _buildAuthForm(),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  /// Build the authentication form based on the current auth mode.
  Widget _buildAuthForm() {
    return Form(
      key: _formKey,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Title for current mode
          Text(
            _authMode == AuthMode.signIn
                ? 'Sign In'
                : _authMode == AuthMode.signUp
                    ? 'Hello, Friend!'
                    : 'Forgot Password',
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: AppColors.primaryBlue,
            ),
          ),
          const SizedBox(height: 16),
          if (_authMode == AuthMode.signUp)
            Text(
              'Enter your personal details and start your journey with us.',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16, color: Colors.black54),
            ),
          const SizedBox(height: 24),
          // Email Field
          TextFormField(
            key: const Key('email'),
            decoration: const InputDecoration(labelText: 'Email'),
            keyboardType: TextInputType.emailAddress,
            validator: (value) =>
                (value == null || !value.contains('@')) ? 'Enter a valid email' : null,
            onSaved: (value) => _email = value!.trim(),
          ),
          const SizedBox(height: 16),
          if (_authMode != AuthMode.forgotPassword)
            TextFormField(
              key: const Key('password'),
              decoration: const InputDecoration(labelText: 'Password'),
              obscureText: true,
              validator: (value) => (value == null || value.length < 6)
                  ? 'Password must be at least 6 characters'
                  : null,
              onSaved: (value) => _password = value!.trim(),
            ),
          const SizedBox(height: 16),
          if (_authMode == AuthMode.signUp) ...[
            TextFormField(
              key: const Key('fullName'),
              decoration: const InputDecoration(labelText: 'Full Name'),
              validator: (value) =>
                  (value == null || value.isEmpty) ? 'Full Name is required' : null,
              onSaved: (value) => _fullName = value!.trim(),
            ),
            const SizedBox(height: 16),
            TextFormField(
              key: const Key('phone'),
              decoration: const InputDecoration(labelText: 'Phone'),
              keyboardType: TextInputType.phone,
              validator: (value) =>
                  (value == null || value.isEmpty) ? 'Phone number is required' : null,
              onSaved: (value) => _phone = value!.trim(),
            ),
            const SizedBox(height: 16),
            TextFormField(
              key: const Key('referralCode'),
              decoration: const InputDecoration(labelText: 'Referral Code (Optional)'),
              onSaved: (value) => _referralCode = value?.trim() ?? '',
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _membershipTier,
              items: ['basic', 'ambassador', 'business']
                  .map((tier) => DropdownMenuItem(
                        value: tier,
                        child: Text(tier.toUpperCase()),
                      ))
                  .toList(),
              onChanged: (value) => setState(() {
                _membershipTier = value!;
              }),
              decoration: const InputDecoration(labelText: 'Membership Plan'),
            ),
          ],
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: _submit,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryBlue,
              padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
              textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            child: Text(
              _authMode == AuthMode.signIn
                  ? 'Sign In'
                  : _authMode == AuthMode.signUp
                      ? 'Sign Up'
                      : 'Reset Password',
            ),
          ),
          const SizedBox(height: 16),
          if (_authMode == AuthMode.signIn)
            TextButton(
              onPressed: () => _switchAuthMode(AuthMode.forgotPassword),
              child: const Text('Forgot your password?'),
            ),
          if (_authMode != AuthMode.signUp)
            TextButton(
              onPressed: () => _switchAuthMode(AuthMode.signUp),
              child: const Text('Create an account'),
            ),
          if (_authMode != AuthMode.signIn)
            TextButton(
              onPressed: () => _switchAuthMode(AuthMode.signIn),
              child: const Text('Already have an account? Sign In'),
            ),
        ],
      ),
    );
  }
}
