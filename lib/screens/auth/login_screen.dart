import 'package:flutter/material.dart';
import 'package:ai_coinbox/screens/auth/auth_card.dart';
import 'package:ai_coinbox/screens/auth/sign_in_form.dart';
import 'package:ai_coinbox/screens/auth/sign_up_form.dart';
import 'package:ai_coinbox/screens/auth/forgot_password_form.dart';

// Enum to define the different authentication modes
enum AuthMode { signIn, signUp, forgotPassword }

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  AuthMode _authMode = AuthMode.signIn; // Default authentication mode
  final GlobalKey<AuthCardState> _authCardKey = GlobalKey<AuthCardState>();

  // Method to switch the authentication mode and trigger the card flip
  void _switchAuthMode(AuthMode mode) {
    if (_authMode != mode) {
      setState(() {
        _authMode = mode;
      });
      _authCardKey.currentState?.flipToSide(mode);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Theme.of(context).primaryColor.withOpacity(0.8),
              Theme.of(context).colorScheme.secondary.withOpacity(0.8),
            ],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'AI CoinBox',
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 30),
                    // AuthCard widget to handle different authentication forms
                    AuthCard(
                      key: _authCardKey,
                      signInForm: SignInForm(
                        onForgotPassword: () => _switchAuthMode(AuthMode.forgotPassword),
                        onSignUp: () => _switchAuthMode(AuthMode.signUp),
                      ),
                      signUpForm: SignUpForm(
                        onSignIn: () => _switchAuthMode(AuthMode.signIn),
                      ),
                      forgotPasswordForm: ForgotPasswordForm(
                        onBackToSignIn: () => _switchAuthMode(AuthMode.signIn),
                      ),
                      initialSide: _authMode == AuthMode.signIn
                          ? AuthCardSide.signIn
                          : (_authMode == AuthMode.signUp
                              ? AuthCardSide.signUp
                              : AuthCardSide.forgotPassword),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}