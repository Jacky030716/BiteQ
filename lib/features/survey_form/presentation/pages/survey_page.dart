import 'package:biteq/core/widgets/custom_app_bar.dart';
import 'package:biteq/features/survey_form/presentation/viewmodel/survey_view_model.dart';
import 'package:biteq/features/survey_form/presentation/widgets/survey_questions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class SurveyPage extends ConsumerWidget {
  const SurveyPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: CustomAppBar(
        title: 'Take Survey',
        onLeadingPressed: () => _handleBackNavigation(context, ref),
      ),
      body: const Padding(
        padding: EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
        child: SurveyQuestions(),
      ),
    );
  }

  void _handleBackNavigation(BuildContext context, WidgetRef ref) {
    final viewModel = ref.read(surveyViewModelProvider.notifier);

    if (viewModel.isFirstQuestion) {
      context.go('/sign-in');
    } else {
      viewModel.moveToPreviousQuestion();
    }
  }
}
