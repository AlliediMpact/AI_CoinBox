// File: lib/screens/auth/auth_screen.dart

import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../constants/app_colors.dart';
import '../../providers/user_provider.dart';
import '../../services/firebase_service.dart';
import '../../services/paystack_service.dart';
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
  bool _isLoading = false; // Track loading state

  // Unique GlobalKeys for each form.
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
    // Initialize the animation controller for the flip effect.
    _controller = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _flipAnimation = Tween<double>(begin: pi, end: 0.0).animate(
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
    // Validate the current form based on the mode.
    if (_authMode == AuthMode.signIn && !_signInFormKey.currentState!.validate()) return;
    if (_authMode == AuthMode.signUp && !_signUpFormKey.currentState!.validate()) return;
    if (_authMode == AuthMode.forgotPassword && !_forgotPasswordFormKey.currentState!.validate()) return;

    // Save form data.
    if (_authMode == AuthMode.signIn) {
      _signInFormKey.currentState!.save();
    } else if (_authMode == AuthMode.signUp) {
      _signUpFormKey.currentState!.save();
    } else if (_authMode == AuthMode.forgotPassword) {
      _forgotPasswordFormKey.currentState!.save();
    }

    setState(() {
      _isLoading = true; // Start loading
    });

    try {
      if (_authMode == AuthMode.signIn) {
        // Sign in with Firebase Authentication.
        UserCredential userCredential = await FirebaseService.auth
            .signInWithEmailAndPassword(email: _email, password: _password);
        await _loadUserProfile(userCredential.user);
        Navigator.pushReplacementNamed(context, '/home');
      } else if (_authMode == AuthMode.signUp) {
        // Sign up and create user profile in Firestore.
        UserCredential userCredential = await FirebaseService.auth
            .createUserWithEmailAndPassword(email: _email, password: _password);
        String uid = userCredential.user!.uid;
        await FirebaseService.firestore.collection('users').doc(uid).set({
          'fullName': _fullName,
          'email': _email,
          'phone': _phone,
          'referralCode': _referralCode,
          'membershipTier': _membershipTier,
          'loanLimit': _getLoanLimit(_membershipTier),
          'investmentLimit': _getInvestmentLimit(_membershipTier),
          'walletBalance': 0.0,
          'commissionBalance': 0.0,
        });
        await _loadUserProfile(userCredential.user);
        Navigator.pushReplacementNamed(context, '/home');
      } else if (_authMode == AuthMode.forgotPassword) {
        // Forgot password logic.
        await FirebaseService.auth.sendPasswordResetEmail(email: _email);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Password reset email sent.")),
        );
        _switchAuthMode(AuthMode.signIn);
      }
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Authentication error: ${error.toString()}")),
      );
    } finally {
      setState(() {
        _isLoading = false; // Stop loading
      });
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
          Provider.of<UserProvider>(context, listen: false)
              .setProfileData(userDoc.data() as Map<String, dynamic>);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("User profile not found for UID: ${user.uid}")),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error loading user profile: ${e.toString()}")),
        );
      }
    }
  }

  /// Function to send OTP (placeholder).
  Future<void> _sendOTP() async {
    if (!_signInFormKey.currentState!.validate()) return;
    _signInFormKey.currentState!.save();
    try {
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

  /// Function to verify OTP (placeholder).
  Future<void> _verifyOTP() async {
    if (_otp.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please enter the OTP.")),
      );
      return;
    }
    try {
      await Future.delayed(const Duration(seconds: 2));
      Navigator.pushReplacementNamed(context, '/home');
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Invalid OTP. Please try again.")),
      );
    }
  }

  /// Function to handle Paystack payment.
  Future<void> _handlePaystackPayment() async {
    if (!_signUpFormKey.currentState!.validate()) return;
    _signUpFormKey.currentState!.save();

    setState(() {
      _isLoading = true; // Start loading
    });

    try {
      final response = await PaystackService.initializeTransaction(
        email: _email,
        amount: _getMembershipPrice(_membershipTier) * 100,
      );
      final authorizationUrl = response['data']['authorization_url'];
      final reference = response['data']['reference'];
      if (await canLaunchUrl(Uri.parse(authorizationUrl))) {
        await launchUrl(Uri.parse(authorizationUrl));
        final verificationResponse = await PaystackService.verifyTransaction(reference);
        if (verificationResponse['data']['status'] == 'success') {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Payment successful. Reference: $reference')),
          );
          await _submit();
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Payment verification failed.')),
          );
        }
      } else {
        throw Exception('Could not launch payment URL.');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
      );
    } finally {
      setState(() {
        _isLoading = false; // Stop loading
      });
    }
  }

  int _getMembershipPrice(String tier) {
    switch (tier) {
      case 'basic':
        return 550;
      case 'ambassador':
        return 1100;
      case 'vip':
        return 5500;
      case 'business':
        return 11000;
      default:
        return 550;
    }
  }

  int _getLoanLimit(String tier) {
    switch (tier) {
      case 'basic':
        return 500;
      case 'ambassador':
        return 1000;
      case 'vip':
        return 5000;
      case 'business':
        return 10000;
      default:
        return 500;
    }
  }

  int _getInvestmentLimit(String tier) {
    switch (tier) {
      case 'basic':
        return 5000;
      case 'ambassador':
        return 10000;
      case 'vip':
        return 50000;
      case 'business':
        return 100000;
      default:
        return 5000;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: _isLoading
              ? const CircularProgressIndicator() // Show loading indicator
              : _buildAuthForm() ?? const Text('Something went wrong. Please try again.'),
        ),
      ),
    );
  }

  /// Custom flip transition using AnimatedSwitcher to ensure forms are always upright.
  Widget _buildAuthForm() {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 500),
      transitionBuilder: (Widget child, Animation<double> animation) {
        // Rotate from 180 degrees to 0.
        final rotateAnim = Tween<double>(begin: pi, end: 0.0).animate(animation);
        return AnimatedBuilder(
          animation: rotateAnim,
          child: child,
          builder: (context, child) {
            // Check if the widget is in the second half of the transition.
            double angle = rotateAnim.value;
            // If angle is greater than 90 degrees, flip the child so it remains upright.
            if (angle > (pi / 2)) {
              return Transform(
                transform: Matrix4.rotationY(angle - pi),
                alignment: Alignment.center,
                child: child,
              );
            } else {
              return Transform(
                transform: Matrix4.rotationY(angle),
                alignment: Alignment.center,
                child: child,
              );
            }
          },
        );
      },
      child: _buildFormForMode(),
    );
  }

  /// Returns the correct form widget based on the current auth mode.
  Widget _buildFormForMode() {
    switch (_authMode) {
      case AuthMode.signIn:
        return Container(key: const ValueKey(AuthMode.signIn), child: _buildSignInForm(context));
      case AuthMode.signUp:
        return Container(key: const ValueKey(AuthMode.signUp), child: _buildSignUpForm(context));
      case AuthMode.forgotPassword:
        return Container(key: const ValueKey(AuthMode.forgotPassword), child: _buildForgotPasswordForm(context));
      default:
        return Container();
    }
  }

  // Build the sign-in form.
  Widget _buildSignInForm(BuildContext context) {
    return Form(
      key: _signInFormKey,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SvgPicture.asset(
              'assets/CoinBoxLogo01.svg',
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
              decoration: InputDecoration(
                labelText: 'Email',
                hintText: 'Enter your email',
                border: const OutlineInputBorder(),
                prefixIcon: const Icon(Icons.email_outlined),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: AppColors.primaryBlue),
                ),
                errorStyle: TextStyle(color: AppColors.errorRed), // Error text color
              ),
              keyboardType: TextInputType.emailAddress,
              validator: (value) {
                if (value == null || value.isEmpty) return 'Email is required';
                if (!value.contains('@')) return 'Enter a valid email';
                return null;
              },
              onSaved: (value) => _email = value!.trim(),
            ),
            const SizedBox(height: 16),
            TextFormField(
              key: const Key('password'),
              decoration: InputDecoration(
                labelText: 'Password',
                hintText: 'Enter your password',
                border: const OutlineInputBorder(),
                prefixIcon: const Icon(Icons.lock_outline),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: AppColors.primaryBlue),
                ),
                errorStyle: TextStyle(color: AppColors.errorRed), // Error text color
              ),
              obscureText: true,
              validator: (value) {
                if (value == null || value.isEmpty) return 'Password is required';
                if (value.length < 6) return 'Password must be at least 6 characters';
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

  // Build the sign-up form.
  Widget _buildSignUpForm(BuildContext context) {
    return Form(
      key: _signUpFormKey,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SvgPicture.asset(
              'assets/CoinBoxLogo01.svg',
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
              decoration: InputDecoration(
                labelText: 'Full Name',
                hintText: 'Enter your full name',
                border: const OutlineInputBorder(),
                prefixIcon: const Icon(Icons.person_outline),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: AppColors.primaryBlue),
                ),
                errorStyle: TextStyle(color: AppColors.errorRed), // Error text color
              ),
              validator: (value) {
                if (value == null || value.isEmpty) return 'Full Name is required';
                return null;
              },
              onSaved: (value) => _fullName = value!.trim(),
            ),
            const SizedBox(height: 16),
            TextFormField(
              key: const Key('email'),
              decoration: InputDecoration(
                labelText: 'Email',
                hintText: 'Enter your email',
                border: const OutlineInputBorder(),
                prefixIcon: const Icon(Icons.email_outlined),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: AppColors.primaryBlue),
                ),
                errorStyle: TextStyle(color: AppColors.errorRed), // Error text color
              ),
              keyboardType: TextInputType.emailAddress,
              validator: (value) {
                if (value == null || value.isEmpty) return 'Email is required';
                if (!value.contains('@')) return 'Enter a valid email';
                return null;
              },
              onSaved: (value) => _email = value!.trim(),
            ),
            const SizedBox(height: 16),
            TextFormField(
              key: const Key('phone'),
              decoration: InputDecoration(
                labelText: 'Phone',
                hintText: 'Enter your phone number',
                border: const OutlineInputBorder(),
                prefixIcon: const Icon(Icons.phone_outlined),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: AppColors.primaryBlue),
                ),
                errorStyle: TextStyle(color: AppColors.errorRed), // Error text color
              ),
              keyboardType: TextInputType.phone,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              validator: (value) {
                if (value == null || value.isEmpty) return 'Phone number is required';
                if (value.length < 10) return 'Enter a valid phone number';
                return null;
              },
              onSaved: (value) => _phone = value!.trim(),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _membershipTier,
              items: [
                {'tier': 'basic', 'price': 550, 'refundable': 500},
                {'tier': 'ambassador', 'price': 1100, 'refundable': 1000},
                {'tier': 'vip', 'price': 5500, 'refundable': 5000},
                {'tier': 'business', 'price': 11000, 'refundable': 10000},
              ].map<DropdownMenuItem<String>>((item) {
                return DropdownMenuItem<String>(
                  value: item['tier'] as String,
                  child: Text(
                      '${(item['tier'] as String).toUpperCase()} (R${item['price']}) - Refundable R${item['refundable']}'),
                );
              }).toList(),
              onChanged: (value) => setState(() {
                _membershipTier = value!;
              }),
              decoration: InputDecoration(
                labelText: 'Membership Plan',
                border: const OutlineInputBorder(),
                prefixIcon: const Icon(Icons.card_membership),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: AppColors.primaryBlue),
                ),
                errorStyle: TextStyle(color: AppColors.errorRed), // Error text color
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

  // Build the forgot password form.
  Widget _buildForgotPasswordForm(BuildContext context) {
    return Form(
      key: _forgotPasswordFormKey,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SvgPicture.asset(
              'assets/CoinBoxLogo01.svg',
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
            TextFormField(
              key: const Key('email'),
              decoration: InputDecoration(
                labelText: 'Email',
                hintText: 'Enter your email',
                border: const OutlineInputBorder(),
                prefixIcon: const Icon(Icons.email_outlined),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: AppColors.primaryBlue),
                ),
                errorStyle: TextStyle(color: AppColors.errorRed), // Error text color
              ),
              keyboardType: TextInputType.emailAddress,
              validator: (value) {
                if (value == null || value.isEmpty) return 'Email is required';
                if (!value.contains('@')) return 'Enter a valid email';
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
