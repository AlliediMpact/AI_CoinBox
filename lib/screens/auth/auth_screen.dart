import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:math';

enum AuthMode { signIn, signUp, forgotPassword }

class AuthScreen extends StatefulWidget {
  const AuthScreen({Key? key}) : super(key: key);

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> with SingleTickerProviderStateMixin {
  AuthMode _authMode = AuthMode.signIn;
  final _formKey = GlobalKey<FormState>();
  late AnimationController _controller;
  late Animation<double> _flipAnimation;

  // Form fields
  String _email = '';
  String _password = '';
  String _fullName = '';
  String _phone = '';
  String _referralCode = '';
  String _selectedMembershipTier = 'Basic';
  bool _isLoading = false;

  final List<String> _membershipTiers = ['Basic', 'Ambassador', 'Business'];

  @override
  void initState() {
    super.initState();
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

  void _switchAuthMode(AuthMode mode) {
    if (_authMode != mode) {
      setState(() {
        _authMode = mode;
      });
      if (mode == AuthMode.signUp || mode == AuthMode.forgotPassword) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    _formKey.currentState!.save();

    setState(() => _isLoading = true);

    try {
      if (_authMode == AuthMode.signIn) {
        await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: _email,
          password: _password,
        );
      } else if (_authMode == AuthMode.signUp) {
        final userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: _email,
          password: _password,
        );

        // Store additional user details in Firestore
        await FirebaseFirestore.instance.collection('users').doc(userCredential.user!.uid).set({
          'fullName': _fullName,
          'email': _email,
          'phone': _phone,
          'membershipTier': _selectedMembershipTier,
          'referralCode': _referralCode,
          'kycStatus': 'pending',
          'createdAt': FieldValue.serverTimestamp(),
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Account created successfully!')),
        );
      } else if (_authMode == AuthMode.forgotPassword) {
        await FirebaseAuth.instance.sendPasswordResetEmail(email: _email);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Password reset email sent!')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Widget _buildSignInForm() {
    return Column(
      children: [
        const Text(
          'Sign In',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        TextFormField(
          decoration: const InputDecoration(labelText: 'Email'),
          keyboardType: TextInputType.emailAddress,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter your email';
            }
            return null;
          },
          onSaved: (value) => _email = value!,
        ),
        const SizedBox(height: 16),
        TextFormField(
          decoration: const InputDecoration(labelText: 'Password'),
          obscureText: true,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter your password';
            }
            return null;
          },
          onSaved: (value) => _password = value!,
        ),
        const SizedBox(height: 16),
        TextButton(
          onPressed: () => _switchAuthMode(AuthMode.forgotPassword),
          child: const Text('Forgot your password?'),
        ),
        const SizedBox(height: 24),
        if (_isLoading)
          const CircularProgressIndicator()
        else
          ElevatedButton(
            onPressed: _submit,
            child: const Text('Sign In'),
          ),
      ],
    );
  }

  Widget _buildSignUpForm() {
    return Column(
      children: [
        const Text(
          'Hello, Friend!',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        const Text(
          'Enter your personal details and start your journey with us.',
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 16),
        TextFormField(
          decoration: const InputDecoration(labelText: 'Full Name'),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter your full name';
            }
            return null;
          },
          onSaved: (value) => _fullName = value!,
        ),
        const SizedBox(height: 16),
        TextFormField(
          decoration: const InputDecoration(labelText: 'Email'),
          keyboardType: TextInputType.emailAddress,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter your email';
            }
            if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
              return 'Please enter a valid email address';
            }
            return null;
          },
          onSaved: (value) => _email = value!,
        ),
        const SizedBox(height: 16),
        TextFormField(
          decoration: const InputDecoration(labelText: 'Password'),
          obscureText: true,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter your password';
            }
            if (value.length < 6) {
              return 'Password must be at least 6 characters long';
            }
            return null;
          },
          onSaved: (value) => _password = value!,
        ),
        const SizedBox(height: 16),
        TextFormField(
          decoration: const InputDecoration(labelText: 'Phone'),
          keyboardType: TextInputType.phone,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter your phone number';
            }
            if (!RegExp(r'^\d{10,15}$').hasMatch(value)) {
              return 'Please enter a valid phone number';
            }
            return null;
          },
          onSaved: (value) => _phone = value!,
        ),
        const SizedBox(height: 16),
        DropdownButtonFormField<String>(
          value: _selectedMembershipTier,
          items: _membershipTiers
              .map((tier) => DropdownMenuItem(
                    value: tier,
                    child: Text(tier),
                  ))
              .toList(),
          onChanged: (value) {
            setState(() {
              _selectedMembershipTier = value!;
            });
          },
          decoration: const InputDecoration(labelText: 'Membership Tier'),
        ),
        const SizedBox(height: 16),
        TextFormField(
          decoration: const InputDecoration(labelText: 'Referral Code (Optional)'),
          onSaved: (value) => _referralCode = value ?? '',
        ),
        const SizedBox(height: 24),
        if (_isLoading)
          const CircularProgressIndicator()
        else
          ElevatedButton(
            onPressed: _submit,
            child: const Text('Sign Up'),
          ),
      ],
    );
  }

  Widget _buildForgotPasswordForm() {
    return Column(
      children: [
        const Text(
          'Forgot Password',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        TextFormField(
          decoration: const InputDecoration(labelText: 'Email'),
          keyboardType: TextInputType.emailAddress,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter your email';
            }
            return null;
          },
          onSaved: (value) => _email = value!,
        ),
        const SizedBox(height: 24),
        if (_isLoading)
          const CircularProgressIndicator()
        else
          ElevatedButton(
            onPressed: _submit,
            child: const Text('Reset Password'),
          ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    print('Rendering AuthScreen');
    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            // Gradient background
            Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF193281), Color(0xFF5e17eb)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
            ),
            Center(
              child: AnimatedBuilder(
                animation: _flipAnimation,
                builder: (context, child) {
                  final isFlipped = _flipAnimation.value >= 0.5;
                  return Transform(
                    transform: Matrix4.rotationY(pi * _flipAnimation.value),
                    alignment: Alignment.center,
                    child: Transform(
                      alignment: Alignment.center,
                      transform: isFlipped
                          ? Matrix4.rotationY(pi)
                          : Matrix4.identity(),
                      child: Container(
                        width: 400,
                        padding: const EdgeInsets.all(16.0),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 10,
                              offset: const Offset(0, 5),
                            ),
                          ],
                        ),
                        child: Form(
                          key: _formKey,
                          child: isFlipped
                              ? (_authMode == AuthMode.signUp
                                  ? _buildSignUpForm()
                                  : _buildForgotPasswordForm())
                              : _buildSignInForm(),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
