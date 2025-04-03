import 'package:biteq/core/theme/_app.Palette.dart';
import 'package:flutter/material.dart';

class CustomTextField extends StatelessWidget {
  final TextEditingController controller;
  final String labelText;
  final String? errorText;
  final IconData prefixIcon;
  final bool obscureText;
  final ValueChanged<String> onChanged;

  const CustomTextField({
    super.key,
    required this.controller,
    required this.labelText,
    this.errorText,
    required this.prefixIcon,
    this.obscureText = false,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        labelText: labelText,
        errorText: errorText,
        errorStyle: const TextStyle(
          color: Colors.red,
          fontSize: 12,
          overflow: TextOverflow.visible,
        ),
        labelStyle: TextStyle(color: Palette.placeholder),
        floatingLabelStyle: TextStyle(color: Palette.primary),
        prefixIcon: Padding(
          padding: const EdgeInsets.only(left: 15, right: 10),
          child: Icon(prefixIcon, color: Palette.primary),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.0),
          borderSide: BorderSide(color: Palette.placeholder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.0),
          borderSide: BorderSide(color: Palette.primary, width: 2),
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.0),
          borderSide: BorderSide(color: Palette.primary),
        ),
        contentPadding: const EdgeInsets.symmetric(
          vertical: 15,
          horizontal: 20,
        ),
      ),
      obscureText: obscureText,
      onChanged: onChanged,
    );
  }
}
