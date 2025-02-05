import 'package:flutter/material.dart';

class CustomTextFieldDecoration {
  static const Color primaryColor = Color(0xFF2193b0);
  static const Color greyColor = Colors.grey;

  static InputDecoration buildDecoration({
    required String labelText,
    double borderRadius = 10,
    EdgeInsetsGeometry contentPadding =
        const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
  }) {
    return InputDecoration(
      labelText: labelText,
      labelStyle: const TextStyle(color: primaryColor),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(borderRadius),
        borderSide: const BorderSide(color: primaryColor),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(borderRadius),
        borderSide: const BorderSide(color: greyColor),
      ),
      contentPadding: contentPadding,
    );
  }
}
