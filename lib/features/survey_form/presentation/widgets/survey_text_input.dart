import 'package:biteq/core/theme/_app.Palette.dart';
import 'package:flutter/material.dart';

class SurveyTextInput extends StatelessWidget {
  final TextEditingController inputController;
  final Map<String, dynamic> currentQuestion;

  const SurveyTextInput({
    super.key,
    required this.inputController,
    required this.currentQuestion,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 50,
      child: TextField(
        controller: inputController,
        decoration: InputDecoration(
          hintText: currentQuestion['placeholder'],
          contentPadding: const EdgeInsets.symmetric(
            vertical: 15,
            horizontal: 20,
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
        ),
        keyboardType: TextInputType.number, // For numeric input
      ),
    );
  }
}
