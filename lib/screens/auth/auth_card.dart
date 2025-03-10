import 'dart:math';
import 'package:flutter/material.dart';

enum AuthCardSide { signIn, signUp, forgotPassword }

class AuthCard extends StatefulWidget {
  final Widget signInForm;
  final Widget signUpForm;
  final Widget forgotPasswordForm;
  final AuthCardSide initialSide;

  const AuthCard({
    Key? key,
    required this.signInForm,
    required this.signUpForm,
    required this.forgotPasswordForm,
    this.initialSide = AuthCardSide.signIn,
  }) : super(key: key);

  @override
  State<AuthCard> createState() => _AuthCardState();
}

class _AuthCardState extends State<AuthCard> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _rotationAnimation;
  
  AuthCardSide _currentSide = AuthCardSide.signIn;
  bool _isFlipping = false;

  @override
  void initState() {
    super.initState();
    _currentSide = widget.initialSide;
    
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    
    _rotationAnimation = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOutBack,
      ),
    );
    
    _animationController.addStatusListener((status) {
      if (status == AnimationStatus.completed || status == AnimationStatus.dismissed) {
        setState(() {
          _isFlipping = false;
        });
      }
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void flipToSide(AuthCardSide side) {
    if (_currentSide == side || _isFlipping) return;
    
    setState(() {
      _isFlipping = true;
    });
    
    if ((_currentSide == AuthCardSide.signIn && side == AuthCardSide.signUp) ||
        (_currentSide == AuthCardSide.forgotPassword && side == AuthCardSide.signIn) ||
        (_currentSide == AuthCardSide.signUp && side == AuthCardSide.forgotPassword)) {
      _animationController.forward();
    } else {
      _animationController.reverse();
    }
    
    Future.delayed(const Duration(milliseconds: 400), () {
      setState(() {
        _currentSide = side;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _rotationAnimation,
      builder: (context, child) {
        final isFirstHalf = _rotationAnimation.value < 0.5;
        
        return Transform(
          transform: Matrix4.identity()
            ..setEntry(3, 2, 0.001)
            ..rotateY(pi * _rotationAnimation.value),
          alignment: Alignment.center,
          child: _buildCardContent(isFirstHalf),
        );
      },
    );
  }

  Widget _buildCardContent(bool isFirstHalf) {
    // Determine which side to show based on animation and current side
    final showFront = isFirstHalf 
        ? _currentSide == AuthCardSide.signIn 
        : _currentSide != AuthCardSide.signIn;
    
    if (showFront) {
      // Show the front side (Login or the side we're flipping to)
      switch (_currentSide) {
        case AuthCardSide.signIn:
          return widget.signInForm;
        case AuthCardSide.signUp:
          return widget.signUpForm;
        case AuthCardSide.forgotPassword:
          return widget.forgotPasswordForm;
      }
    } else {
      // Show the back side (flipped content)
      switch (_currentSide) {
        case AuthCardSide.signIn:
          return Transform(
            transform: Matrix4.identity()..rotateY(pi),
            alignment: Alignment.center,
            child: widget.signUpForm,
          );
        case AuthCardSide.signUp:
          return Transform(
            transform: Matrix4.identity()..rotateY(pi),
            alignment: Alignment.center,
            child: widget.forgotPasswordForm,
          );
        case AuthCardSide.forgotPassword:
          return Transform(
            transform: Matrix4.identity()..rotateY(pi),
            alignment: Alignment.center,
            child: widget.signInForm,
          );
      }
    }
  }
}