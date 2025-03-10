import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../widgets/custom_button.dart';
import '../../providers/user_provider.dart';
import '../../models/user_profile.dart';
import '../../services/firebase_service.dart';
import '../../services/referral_service.dart';
import '../../utils/error_handler.dart';

class SignUpForm extends StatefulWidget {
  final VoidCallback onSignIn;

  const SignUpForm({
    Key? key,
    required this.onSignIn,
  }) : super(key: key);

  @override
  State<SignUpForm> createState() => _SignUpFormState();
}

class _SignUpFormState extends State<SignUpForm> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _nameController = TextEditingController();
  final _referralCodeController = TextEditingController();
  
  bool _isLoading = false;
  bool _isReferralCodeValid = true;
  String _referralErrorMessage = '';

  // Method to validate referral code
  Future<void> _validateReferralCode() async {
    if (_referralCodeController.text.isEmpty) {
      setState(() {
        _isReferralCodeValid = true;
        _referralErrorMessage = '';
      });
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final isValid = await ReferralService.isReferralCodeValid(
        _referralCodeController.text.trim(),
      );
      
      setState(() {
        _isReferralCodeValid = isValid;
        _referralErrorMessage = isValid ? '' : 'Invalid referral code';
      });
    } catch (e, stackTrace) {
      ErrorHandler.logError(e, stackTrace: stackTrace);
      setState(() {
        _isReferralCodeValid = false;
        _referralErrorMessage = 'Error validating referral code';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // Method to handle form submission
  Future<void> _submit() async {
    // Validate form
    if (!_formKey.currentState!.validate()) return;
    
    // Validate referral code if provided
    if (_referralCodeController.text.isNotEmpty && !_isReferralCodeValid) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(_referralErrorMessage)),
      );
      return;
    }

    setState(() => _isLoading = true);
    
    try {
      // Use AuthService to sign up
      final userCredential = await FirebaseService.authService.signUpWithEmailAndPassword(
        _emailController.text.trim(),
        _passwordController.text.trim(),
      );

      // Generate a referral code for the new user
      final referralCode = await ReferralService.generateReferralCode(
        userCredential.user!.uid,
      );

      // Create user profile in the database
      await UserProfile.create(
        userCredential.user!.uid,
        {
          'email': _emailController.text.trim(),
          'name': _nameController.text.trim(),
          'referralCode': referralCode,
          'membershipPlan': 'basic', // Default to basic plan
        },
      );

      // Process referral if a code was provided
      if (_referralCodeController.text.isNotEmpty) {
        await ReferralService.processReferral(
          _referralCodeController.text.trim(),
          userCredential.user!.uid,
          _nameController.text.trim(),
        );
      }

      // Successful sign-up, update user provider and navigate
      Provider.of<UserProvider>(context, listen: false).setUser(userCredential.user);
      
      if (mounted) {
        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Account created successfully!')),
        );
        
        // Navigate to home screen
        Navigator.pushReplacementNamed(context, '/home');
      }
    } catch (e, stackTrace) {
      // Handle errors with a user-friendly message
      ErrorHandler.handleAuthError(context, e, stackTrace: stackTrace);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _nameController.dispose();
    _referralCodeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Name input field
          TextFormField(
            controller: _nameController,
            decoration: const InputDecoration(labelText: 'Name'),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter your name!';
              }
              return null;
            },
          ),
          
          // Email input field
          TextFormField(
            controller: _emailController,
            decoration: const InputDecoration(labelText: 'Email'),
            keyboardType: TextInputType.emailAddress,
            validator: (value) {
              if (value == null || !value.contains('@')) {
                return 'Invalid email!';
              }
              return null;
            },
          ),
          
          // Password input field
          TextFormField(
            controller: _passwordController,
            decoration: const InputDecoration(labelText: 'Password'),
            obscureText: true,
            validator: (value) {
              if (value == null || value.length < 5) {
                return 'Password is too short!';
              }
              return null;
            },
          ),
          
          // Referral code input field
          TextFormField(
            controller: _referralCodeController,
            decoration: InputDecoration(
              labelText: 'Referral Code (Optional)',
              errorText: !_isReferralCodeValid ? _referralErrorMessage : null,
              suffixIcon: _referralCodeController.text.isNotEmpty
                  ? IconButton(
                      icon: Icon(
                        _isReferralCodeValid ? Icons.check_circle : Icons.error,
                        color: _isReferralCodeValid ? Colors.green : Colors.red,
                      ),
                      onPressed: _validateReferralCode,
                    )
                  : null,
            ),
            onChanged: (value) {
              if (value.isEmpty) {
                setState(() {
                  _isReferralCodeValid = true;
                  _referralErrorMessage = '';
                });
              }
            },
            onEditingComplete: _validateReferralCode,
          ),
          
          const SizedBox(height: 20),
          
          // Loading indicator or sign-up button
          if (_isLoading)
            const CircularProgressIndicator()
          else
            CustomButton(
              text: 'Sign Up',
              onPressed: _submit,
            ),
          
          const SizedBox(height: 10),
          
          // Sign in button
          TextButton(
            onPressed: widget.onSignIn,
            child: const Text('Already have an account? Sign In'),
          ),
        ],
      ),
    );
  }
}
