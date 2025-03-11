// File: lib/screens/auth/login_screen.dart

import 'package:flutter/material.dart';
import '../../widgets/auth_card.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final GlobalKey<AuthCardState> _authCardKey = GlobalKey<AuthCardState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Login"),
      ),
      body: Center(
        child: AuthCard(key: _authCardKey),
      ),
    );
  }
}