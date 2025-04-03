import 'package:biteq/core/theme/_app.Palette.dart';
import 'package:biteq/features/survey_form/data/questions.dart';
import 'package:biteq/features/survey_form/presentation/viewmodel/survey_view_model.dart';
import 'package:biteq/features/survey_form/presentation/widgets/survey_text_input.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class SurveyQuestions extends ConsumerWidget {
  const SurveyQuestions({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final viewModel = ref.watch(surveyViewModelProvider.notifier);
    final state = ref.watch(surveyViewModelProvider);
    final currentQuestion = viewModel.currentQuestion;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Progress Indicator
            LinearProgressIndicator(
              value: (state.currentQuestionIndex + 1) / questions.length,
              backgroundColor: Palette.placeholder,
              color: Palette.blackText,
            ),
            const SizedBox(height: 32),
            // Current Question
            Text(
              currentQuestion['question'],
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w700,
                color: Palette.blackText,
              ),
              textAlign: TextAlign.left,
            ),
          ],
        ),

        const SizedBox(height: 32),

        // Render Options or Input Field
        if (currentQuestion['type'] == 'options')
          _buildOptionsQuestion(context, ref, currentQuestion)
        else if (currentQuestion['type'] == 'input')
          SurveyTextInput(
            inputController: viewModel.inputController,
            currentQuestion: currentQuestion,
          ),

        // Error message if any
        if (state.errorMessage != null)
          Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: Text(
              state.errorMessage!,
              style: TextStyle(color: Colors.red[700], fontSize: 14),
            ),
          ),

        const SizedBox(height: 60),

        SizedBox(
          width: double.infinity,
          height: 45,
          child: ElevatedButton(
            onPressed:
                state.isSubmitting
                    ? null
                    : () => _handleNextPress(context, ref),
            style: ElevatedButton.styleFrom(backgroundColor: Palette.primary),
            child:
                state.isSubmitting
                    ? const CircularProgressIndicator(color: Colors.white)
                    : Text(
                      viewModel.isLastQuestion ? 'Submit' : 'Next',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: Colors.white,
                      ),
                    ),
          ),
        ),
      ],
    );
  }

  Widget _buildOptionsQuestion(
    BuildContext context,
    WidgetRef ref,
    Map<String, dynamic> currentQuestion,
  ) {
    final viewModel = ref.watch(surveyViewModelProvider.notifier);
    final state = ref.watch(surveyViewModelProvider);

    return Column(
      children: List.generate(currentQuestion['options'].length, (index) {
        return GestureDetector(
          onTap: () => viewModel.selectOption(index),
          child: Container(
            width: double.infinity,
            margin: const EdgeInsets.symmetric(vertical: 8.0),
            padding: const EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              color:
                  state.selectedOption == index
                      ? Palette.primary
                      : Colors.grey[100],
              borderRadius: BorderRadius.circular(12.0),
            ),
            child: Text(
              currentQuestion['options'][index],
              textAlign: TextAlign.center,
              style: TextStyle(
                color:
                    state.selectedOption == index
                        ? Palette.whiteText
                        : Palette.blackText,
                fontSize: 16.0,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        );
      }),
    );
  }

  void _handleNextPress(BuildContext context, WidgetRef ref) {
    final viewModel = ref.watch(surveyViewModelProvider.notifier);

    if (viewModel.isLastQuestion) {
      viewModel.submitSurvey(() => {context.go('/home')});
    } else {
      final success = viewModel.moveToNextQuestion();
      if (!success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please select an answer before proceeding'),
            duration: Duration(seconds: 2),
          ),
        );
      }
    }
  }
}
