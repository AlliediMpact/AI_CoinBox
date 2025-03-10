import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../widgets/custom_button.dart';
import '../../providers/user_provider.dart';
import '../../services/firebase_service.dart';

class SignInForm extends StatefulWidget {
  final VoidCallback onSignUp;
  final VoidCallback onForgotPassword;

  const SignInForm({
    Key? key,
    required this.onSignUp,
    required this.onForgotPassword,
  }) : super(key: key);

  @override
  State<SignInForm> createState() => _SignInFormState();
}

class _SignInFormState extends State<SignInForm> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;

  // Method to handle form submission
  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    try {
      // Use AuthService to sign in
      final userCredential = await FirebaseService.authService.signInWithEmailAndPassword(
        _emailController.text.trim(),
        _passwordController.text.trim(),
      );

      // Successful login, update user provider and navigate
      Provider.of<UserProvider>(context, listen: false).setUser(userCredential.user);
      if (mounted) {
        Navigator.pushReplacementNamed(context, '/home');
      }
    } catch (e) {
      // Handle errors with a user-friendly message
      _showErrorDialog('Failed to sign in. Please check your credentials and try again.');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // Method to display error dialog
  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('An Error Occurred!'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
            },
            child: const Text('Okay'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Email input field
          TextFormField(
            controller: _emailController,
            decoration: const InputDecoration(labelText: 'Email'),
            keyboardType: TextInputType.emailAddress,
            validator: (value) {
              if (value == null || !value.contains('@')) {
                return 'Please enter a valid email address.';
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
                return 'Password must be at least 5 characters long.';
              }
              return null;
            },
          ),
          const SizedBox(height: 10),
          // Loading indicator or login button
          if (_isLoading)
            const CircularProgressIndicator()
          else
            CustomButton(
              text: 'Login',
              onPressed: _submit,
            ),
          const SizedBox(height: 10),
          // Forgot password button
          TextButton(
            onPressed: widget.onForgotPassword,
            child: const Text('Forgot Password?'),
          ),
          const SizedBox(height: 10),
          // Sign up button
          TextButton(
            onPressed: widget.onSignUp,
            child: const Text('Sign Up'),
          ),
        ],
      ),
    );
  }
}