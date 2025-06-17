import 'package:biteq/core/theme/_app.Palette.dart';
import 'package:biteq/features/survey_form/data/questions.dart';
import 'package:biteq/features/survey_form/presentation/viewmodel/survey_view_model.dart';
import 'package:biteq/features/survey_form/presentation/widgets/scrollable_input.dart';
import 'package:biteq/features/survey_form/presentation/widgets/survey_text_input.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

// Changed to ConsumerStatefulWidget
class SurveyQuestions extends ConsumerStatefulWidget {
  const SurveyQuestions({super.key});

  @override
  ConsumerState<SurveyQuestions> createState() => _SurveyQuestionsState();
}

class _SurveyQuestionsState extends ConsumerState<SurveyQuestions> {
  @override
  void initState() {
    super.initState();
    // Use Future.microtask to schedule the check after the build phase
    // to avoid setState during build.
    Future.microtask(() {
      final viewModel = ref.read(surveyViewModelProvider.notifier);
    });
  }

  @override
  Widget build(BuildContext context) {
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
        else if (currentQuestion['type'] == 'scrollable_input')
          SurveyScrollableInput(
            key: Key(currentQuestion['question']),
            inputController: viewModel.inputController,
            currentQuestion: currentQuestion,
            minValue: currentQuestion['minValue'] ?? 0,
            maxValue: currentQuestion['maxValue'] ?? 100,
            defaultValue: currentQuestion['defaultValue'] ?? 0,
            unit: currentQuestion['unit'] ?? '',
          )
        else if (currentQuestion['type'] == 'input')
          SurveyTextInput(
            viewModel: viewModel,
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
                      viewModel.isLastQuestion ? 'Submit' : 'Continue',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: Colors.white,
                      ),
                    ),
          ),
        ),
        const SizedBox(height: 20), // Space between buttons

        if (state.hasCompletedSurvey == true) // Only show if explicitly true
          SizedBox(
            width: double.infinity,
            height: 45,
            child: OutlinedButton(
              onPressed:
                  state
                          .isLoadingSurveyStatus // Disable if still checking status
                      ? null
                      : () {
                        context.go('/home'); // Navigate to home screen
                      },
              style: OutlinedButton.styleFrom(
                foregroundColor: Palette.primary,
                side: BorderSide(color: Palette.primary),
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(32),
                ),
              ),
              child:
                  state.isLoadingSurveyStatus
                      ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          color: Colors.grey,
                          strokeWidth: 2,
                        ),
                      )
                      : const Text(
                        "Skip Survey",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
            ),
          ),
        if (state
            .isLoadingSurveyStatus) // Optional: Show a subtle message while checking
          const Padding(
            padding: EdgeInsets.only(top: 8.0),
            child: Text(
              "Checking survey status...",
              style: TextStyle(fontSize: 12, color: Colors.grey),
              textAlign: TextAlign.center,
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
          onTap: () => {viewModel.selectOption(index)},
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
    final viewModel = ref.read(
      surveyViewModelProvider.notifier,
    ); // Use .read for event handlers

    if (viewModel.isLastQuestion) {
      viewModel.submitSurvey(() {
        if (mounted) {
          // Ensure widget is still mounted before navigating
          context.go('/home');
        }
      });
    } else {
      final success = viewModel.moveToNextQuestion();
      if (!success) {
        if (mounted) {
          // Ensure widget is still mounted before showing SnackBar
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
}
