// File: lib/screens/auth/auth_screen.dart

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import '../../constants/app_colors.dart';
import '../../services/firebase_service.dart';
import '../../providers/user_provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'user_role.dart';
import 'package:flutter_svg/flutter_svg.dart'; // Import flutter_svg
import 'package:ai_coinbox/services/paystack_service.dart';
import 'package:url_launcher/url_launcher.dart';

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

  // Separate GlobalKeys for each form
  final _signInFormKey = GlobalKey<FormState>();
  final _signUpFormKey = GlobalKey<FormState>();
  final _forgotPasswordFormKey = GlobalKey<FormState>();

  // Form fields
  String _email = '';
  String _password = '';
  String _fullName = '';
  String _phone = '';
  String _referralCode = '';
  String _membershipTier = 'basic';
  String _otp = '';
  bool _isOTPSent = false;

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
    if (_authMode == AuthMode.signIn && !_signInFormKey.currentState!.validate()) return;
    if (_authMode == AuthMode.signUp && !_signUpFormKey.currentState!.validate()) return;
    if (_authMode == AuthMode.forgotPassword && !_forgotPasswordFormKey.currentState!.validate()) return;

    if (_authMode == AuthMode.signIn) {
      _signInFormKey.currentState!.save();
    } else if (_authMode == AuthMode.signUp) {
      _signUpFormKey.currentState!.save();
    } else if (_authMode == AuthMode.forgotPassword) {
      _forgotPasswordFormKey.currentState!.save();
    }

    try {
      if (_authMode == AuthMode.signIn) {
        // Sign in logic with Firebase
        UserCredential userCredential = await FirebaseService.auth
            .signInWithEmailAndPassword(email: _email, password: _password);

        // Load user profile from Firestore
        await _loadUserProfile(userCredential.user);

        // Update user provider and navigate to home
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

        // Load user profile from Firestore
        await _loadUserProfile(userCredential.user);

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

  /// Loads the user profile from Firestore and updates the UserProvider.
  Future<void> _loadUserProfile(User? user) async {
    if (user != null) {
      try {
        DocumentSnapshot userDoc = await FirebaseService.firestore
            .collection('users')
            .doc(user.uid)
            .get();
        if (userDoc.exists) {
          // Update user provider with profile data
          Provider.of<UserProvider>(context, listen: false)
              .setProfileData(userDoc.data() as Map<String, dynamic>);
        } else {
          print('User document not found for UID: ${user.uid}');
          WidgetsBinding.instance.addPostFrameCallback((_) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text("User profile not found.")),
            );
          });
        }
      } catch (e) {
        print('Error loading user profile: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error loading user profile: ${e.toString()}")),
        );
      }
    } else {
      print('User is null during profile loading.');
    }
  }

  // Function to send OTP to the user's email
  Future<void> _sendOTP() async {
    if (!_signInFormKey.currentState!.validate()) return;
    _signInFormKey.currentState!.save();

    // TODO: Integrate with your backend to send OTP to the user's email
    // Replace this with your actual backend API call
    try {
      // Simulate sending OTP
      await Future.delayed(const Duration(seconds: 2));
      setState(() {
        _isOTPSent = true;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("OTP sent to your email.")),
      );
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to send OTP: ${error.toString()}")),
      );
    }
  }

  // Function to verify OTP
  Future<void> _verifyOTP() async {
    if (_otp.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please enter the OTP.")),
      );
      return;
    }

    // TODO: Integrate with your backend to verify the OTP
    // Replace this with your actual backend API call
    try {
      // Simulate verifying OTP
      await Future.delayed(const Duration(seconds: 2));
      // Assuming OTP is valid, navigate to home
      Navigator.pushReplacementNamed(context, '/home');
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Invalid OTP. Please try again.")),
      );
    }
  }

  // Function to handle Paystack payment using REST API
  Future<void> _handlePaystackPayment() async {
    if (!_signUpFormKey.currentState!.validate()) return;
    _signUpFormKey.currentState!.save();

    try {
      // Initialize the transaction
      final response = await PaystackService.initializeTransaction(
        email: _email,
        amount: _getMembershipPrice(_membershipTier) * 100, // Amount in kobo
      );

      final authorizationUrl = response['data']['authorization_url'];
      final reference = response['data']['reference'];

      // Open the payment page in a browser
      if (await canLaunch(authorizationUrl)) {
        await launch(authorizationUrl);

        // After payment, verify the transaction
        final verificationResponse = await PaystackService.verifyTransaction(reference);

        if (verificationResponse['data']['status'] == 'success') {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Payment successful. Reference: $reference')),
          );
          await _submit(); // Proceed with form submission after successful payment
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Payment verification failed.')),
          );
        }
      } else {
        throw Exception('Could not launch payment URL.');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
      );
    }
  }

  // Get membership price based on tier
  int _getMembershipPrice(String tier) {
    switch (tier) {
      case 'basic':
        return 0;
      case 'ambassador':
        return 10;
      case 'business':
        return 50;
      default:
        return 0;
    }
  }

  // Widget to display OTP input field
  Widget _buildOTPForm() {
    return Column(
      children: [
        TextFormField(
          decoration: const InputDecoration(labelText: 'OTP'),
          keyboardType: TextInputType.number,
          onChanged: (value) => _otp = value,
        ),
        const SizedBox(height: 16),
        ElevatedButton(
          onPressed: _verifyOTP,
          child: const Text('Verify OTP'),
        ),
      ],
    );
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
                transform: Matrix4.identity()
                  ..setEntry(3, 2, 0.001)
                  ..rotateY(angle),
                alignment: Alignment.center,
                child: IndexedStack(
                  index: _authMode == AuthMode.signIn
                      ? 0
                      : _authMode == AuthMode.signUp
                          ? 1
                          : 2,
                  children: [
                    _buildSignInForm(context, isMobile),
                    _buildSignUpForm(context, isMobile),
                    _buildForgotPasswordForm(context, isMobile),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  // Build the sign-in form
  Widget _buildSignInForm(BuildContext context, bool isMobile) {
    return Form(
      key: _signInFormKey, // Use unique key
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SvgPicture.asset(
              'assets/CoinBoxLogo01.svg', // Path to your SVG logo
              height: 70,
            ),
            const SizedBox(height: 24),
            Text(
              'Sign In',
              style: Theme.of(context).textTheme.headlineSmall!.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.primaryBlue,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            TextFormField(
              key: const Key('email'),
              decoration: const InputDecoration(
                labelText: 'Email',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.email_outlined),
              ),
              keyboardType: TextInputType.emailAddress,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Email is required';
                }
                if (!value.contains('@')) {
                  return 'Enter a valid email';
                }
                return null;
              },
              onSaved: (value) => _email = value!.trim(),
            ),
            const SizedBox(height: 16),
            TextFormField(
              key: const Key('password'),
              decoration: const InputDecoration(
                labelText: 'Password',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.lock_outline),
              ),
              obscureText: true,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Password is required';
                }
                if (value.length < 6) {
                  return 'Password must be at least 6 characters';
                }
                return null;
              },
              onSaved: (value) => _password = value!.trim(),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _submit,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryBlue,
                padding: const EdgeInsets.symmetric(vertical: 16),
                textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text('Sign In'),
            ),
            const SizedBox(height: 16),
            TextButton(
              onPressed: () => _switchAuthMode(AuthMode.forgotPassword),
              child: const Text('Forgot your password?'),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text("Don't have an account?"),
                TextButton(
                  onPressed: () => _switchAuthMode(AuthMode.signUp),
                  child: const Text('Create account'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // Build the sign-up form
  Widget _buildSignUpForm(BuildContext context, bool isMobile) {
    return Form(
      key: _signUpFormKey, // Use unique key
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SvgPicture.asset(
              'assets/CoinBoxLogo01.svg', // Path to your SVG logo
              height: 70,
            ),
            const SizedBox(height: 24),
            Text(
              'Create Account',
              style: Theme.of(context).textTheme.headlineSmall!.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.primaryBlue,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            TextFormField(
              key: const Key('fullName'),
              decoration: const InputDecoration(
                labelText: 'Full Name',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.person_outline),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Full Name is required';
                }
                return null;
              },
              onSaved: (value) => _fullName = value!.trim(),
            ),
            const SizedBox(height: 16),
            TextFormField(
              key: const Key('email'),
              decoration: const InputDecoration(
                labelText: 'Email',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.email_outlined),
              ),
              keyboardType: TextInputType.emailAddress,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Email is required';
                }
                if (!value.contains('@')) {
                  return 'Enter a valid email';
                }
                return null;
              },
              onSaved: (value) => _email = value!.trim(),
            ),
            const SizedBox(height: 16),
            TextFormField(
              key: const Key('phone'),
              decoration: const InputDecoration(
                labelText: 'Phone',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.phone_outlined),
              ),
              keyboardType: TextInputType.phone,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Phone number is required';
                }
                if (value.length < 10) {
                  return 'Enter a valid phone number';
                }
                return null;
              },
              onSaved: (value) => _phone = value!.trim(),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _membershipTier,
              items: [
                {'tier': 'basic', 'price': 0},
                {'tier': 'ambassador', 'price': 10},
                {'tier': 'business', 'price': 50},
              ].map<DropdownMenuItem<String>>((item) {
                return DropdownMenuItem<String>(
                  value: item['tier'] as String,
                  child: Text('${(item['tier'] as String).toUpperCase()} (\$${item['price']})'),
                );
              }).toList(),
              onChanged: (value) => setState(() {
                _membershipTier = value!;
              }),
              decoration: const InputDecoration(
                labelText: 'Membership Plan',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.card_membership),
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _handlePaystackPayment,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryBlue,
                padding: const EdgeInsets.symmetric(vertical: 16),
                textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text('Sign Up'),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text("Already have an account?"),
                TextButton(
                  onPressed: () => _switchAuthMode(AuthMode.signIn),
                  child: const Text('Sign In'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // Build the forgot password form
  Widget _buildForgotPasswordForm(BuildContext context, bool isMobile) {
    return Form(
      key: _forgotPasswordFormKey, // Use unique key
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SvgPicture.asset(
              'assets/CoinBoxLogo01.svg', // Path to your SVG logo
              height: 70,
            ),
            const SizedBox(height: 24),
            Text(
              'Reset Password',
              style: Theme.of(context).textTheme.headlineSmall!.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.primaryBlue,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            // Email Field
            TextFormField(
              key: const Key('email'),
              decoration: const InputDecoration(
                labelText: 'Email',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.email_outlined),
              ),
              keyboardType: TextInputType.emailAddress,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Email is required';
                }
                if (!value.contains('@')) {
                  return 'Enter a valid email';
                }
                return null;
              },
              onSaved: (value) => _email = value!.trim(),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _submit,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryBlue,
                padding: const EdgeInsets.symmetric(vertical: 16),
                textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text('Reset Password'),
            ),
            const SizedBox(height: 16),
            TextButton(
              onPressed: () => _switchAuthMode(AuthMode.signIn),
              child: const Text('Back to Sign In'),
            ),
          ],
        ),
      ),
    );
  }
}
