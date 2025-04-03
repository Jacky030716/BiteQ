import 'package:biteq/core/theme/_app.Palette.dart';
import 'package:biteq/features/survey_form/presentation/viewmodel/survey_view_model.dart';
import 'package:flutter/material.dart';

class SurveyTextInput extends StatelessWidget {
  const SurveyTextInput({
    super.key,
    required this.viewModel,
    required this.currentQuestion,
  });

  final SurveyViewModel viewModel;
  final Map<String, dynamic> currentQuestion;

  @override
  Widget build(BuildContext context) {
    // Convert string keyboard type to actual TextInputType
    TextInputType getKeyboardType(String? type) {
      switch (type) {
        case 'text':
          return TextInputType.text;
        case 'number':
          return TextInputType.number;
        case 'phone':
          return TextInputType.phone;
        case 'email':
          return TextInputType.emailAddress;
        case 'multiline':
          return TextInputType.multiline;
        case 'url':
          return TextInputType.url;
        default:
          return TextInputType.text;
      }
    }

    return TextField(
      controller: viewModel.inputController,
      keyboardType: getKeyboardType(currentQuestion['keyboardType'] as String?),
      decoration: InputDecoration(
        hintText: currentQuestion['hintText'],
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.0),
          borderSide: BorderSide(color: Palette.placeholder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.0),
          borderSide: BorderSide(color: Palette.primary),
        ),
      ),
    );
  }
}
