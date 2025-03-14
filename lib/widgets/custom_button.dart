// File: lib/widgets/custom_button.dart

import 'package:flutter/material.dart';

class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final Color btnColor;

  const CustomButton({
    Key? key,
    required this.text,
    required this.onPressed,
    this.btnColor = Colors.blue,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(primary: btnColor),
      onPressed: onPressed,
      child: Text(text),
    );
  }
}
