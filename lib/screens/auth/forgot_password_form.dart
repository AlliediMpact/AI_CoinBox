import 'package:flutter/material.dart';
import '../../widgets/custom_button.dart';
import '../../services/firebase_service.dart';

class ForgotPasswordForm extends StatefulWidget {
  final VoidCallback onBackToSignIn;

  const ForgotPasswordForm({
    Key? key,
    required this.onBackToSignIn,
  }) : super(key: key);

  @override
  State<ForgotPasswordForm> createState() => _ForgotPasswordFormState();
}

class _ForgotPasswordFormState extends State<ForgotPasswordForm> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  bool _isLoading = false;
  bool _isEmailSent = false;

  // Method to handle form submission
  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    try {
      // Use AuthService to send password reset email
      await FirebaseService.authService.sendPasswordResetEmail(
        _emailController.text.trim(),
      );
      // Successful email sent
      setState(() {
        _isEmailSent = true;
      });
    } catch (e) {
      // Handle errors with a user-friendly message
      _showErrorDialog('Failed to send password reset email. Please try again.');
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
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (_isEmailSent)
            const Text(
              'A password reset link has been sent to your email address.',
              textAlign: TextAlign.center,
            )
          else
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
          const SizedBox(height: 20),
          if (_isLoading)
            const CircularProgressIndicator()
          else if (!_isEmailSent)
            CustomButton(
              text: 'Send Reset Link',
              onPressed: _submit,
            ),
          const SizedBox(height: 10),
          TextButton(
            onPressed: widget.onBackToSignIn,
            child: const Text('Back to Sign In'),
          ),
        ],
      ),
    );
  }
}