import 'package:biteq/features/survey_form/data/models/user_survey.dart';
import 'package:biteq/features/survey_form/data/questions.dart';
import 'package:biteq/features/survey_form/domain/repositories/survey_repositories.dart';
import 'package:biteq/features/survey_form/domain/usecase/survey_usecase.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Define a state class to hold all the survey state
class SurveyState {
  final int currentQuestionIndex;
  final List<dynamic> responses;
  final int? selectedOption;
  final bool isSubmitting;
  final String? errorMessage;

  const SurveyState({
    this.currentQuestionIndex = 0,
    required this.responses,
    this.selectedOption,
    this.isSubmitting = false,
    this.errorMessage,
  });

  // Create a copy of the state with updated fields
  SurveyState copyWith({
    int? currentQuestionIndex,
    List<dynamic>? responses,
    int? selectedOption,
    bool? isSubmitting,
    String? errorMessage,
    bool clearSelectedOption = false,
    bool clearErrorMessage = false,
  }) {
    return SurveyState(
      currentQuestionIndex: currentQuestionIndex ?? this.currentQuestionIndex,
      responses: responses ?? this.responses,
      selectedOption:
          clearSelectedOption ? null : (selectedOption ?? this.selectedOption),
      isSubmitting: isSubmitting ?? this.isSubmitting,
      errorMessage:
          clearErrorMessage ? null : (errorMessage ?? this.errorMessage),
    );
  }
}

class SurveyViewModel extends StateNotifier<SurveyState> {
  final TextEditingController inputController = TextEditingController();
  final SurveyUsecase useCase;

  SurveyViewModel(this.useCase)
    : super(
        SurveyState(responses: List.generate(questions.length, (_) => null)),
      ) {
    inputController.addListener(_handleTextInputChange);
  }

  // Getters for convenience
  bool get isFirstQuestion => state.currentQuestionIndex == 0;
  bool get isLastQuestion => state.currentQuestionIndex == questions.length - 1;
  Map<String, dynamic> get currentQuestion =>
      questions[state.currentQuestionIndex];

  // Handle text input changes
  void _handleTextInputChange() {
    if (currentQuestion['type'] == 'input') {
      final text = inputController.text;
      if (text.isNotEmpty) {
        try {
          final value = int.parse(text);
          _updateResponse(value);
        } catch (e) {
          _updateResponse(text);
        }
      }
    }
  }

  // Update response for current question
  void _updateResponse(dynamic value) {
    final responses = List<dynamic>.from(state.responses);
    responses[state.currentQuestionIndex] = value;
    state = state.copyWith(responses: responses, clearErrorMessage: true);
  }

  // Select an option for multiple choice questions
  void selectOption(int index) {
    final selectedValue = currentQuestion['options'][index];

    state = state.copyWith(selectedOption: index, clearErrorMessage: true);
    _updateResponse(selectedValue);
  }

  // Validate current response
  bool validateCurrentResponse() {
    if (currentQuestion['type'] == 'options') {
      if (state.selectedOption == null) {
        state = state.copyWith(errorMessage: 'Please select an option');
        return false;
      }
    } else if (currentQuestion['type'] == 'input') {
      if (inputController.text.isEmpty) {
        state = state.copyWith(errorMessage: 'Please enter a value');
        return false;
      }
    }
    return true;
  }

  // Move to next question
  bool moveToNextQuestion() {
    if (!validateCurrentResponse()) {
      return false;
    }

    if (state.currentQuestionIndex < questions.length - 1) {
      final nextIndex = state.currentQuestionIndex + 1;
      state = state.copyWith(
        currentQuestionIndex: nextIndex,
        clearSelectedOption: true,
        clearErrorMessage: true,
      );

      _prepareCurrentQuestion();
    }
    return true;
  }

  // Move to previous question
  void moveToPreviousQuestion() {
    if (state.currentQuestionIndex > 0) {
      final prevIndex = state.currentQuestionIndex - 1;
      state = state.copyWith(
        currentQuestionIndex: prevIndex,
        clearErrorMessage: true,
      );

      // Update the input controller and selected option for the new question
      _prepareCurrentQuestion();
    }
  }

  // Prepare UI based on current question type and saved response
  void _prepareCurrentQuestion() {
    final response = state.responses[state.currentQuestionIndex];

    if (currentQuestion['type'] == 'options' && response is int) {
      state = state.copyWith(selectedOption: response);
    } else if (currentQuestion['type'] == 'input') {
      inputController.text = response?.toString() ?? '';
    }
  }

  // Reset error message
  void resetError() {
    if (state.errorMessage != null) {
      state = state.copyWith(clearErrorMessage: true);
    }
  }

  // Submit survey
  Future<void> submitSurvey(Function onSuccess) async {
    if (!validateCurrentResponse()) {
      return;
    }

    state = state.copyWith(isSubmitting: true);
    try {
      final survey = mapResponsesToUserSurvey(state.responses);
      await useCase.submitSurvey(survey);

      // Reset survey after successful submission
      state = SurveyState(
        responses: List.generate(questions.length, (_) => null),
      );

      onSuccess();
    } catch (e) {
      state = state.copyWith(
        isSubmitting: false,
        errorMessage: 'Failed to submit survey: ${e.toString()}',
      );
    }
  }

  @override
  void dispose() {
    inputController.removeListener(_handleTextInputChange);
    inputController.dispose();
    super.dispose();
  }
}

UserSurveyModel mapResponsesToUserSurvey(List<dynamic> responses) {
  String safeString(dynamic value) => value?.toString() ?? '';

  return UserSurveyModel(
    gender: safeString(responses[0]),
    age:
        responses[1] is int
            ? responses[1]
            : int.tryParse(responses[1]?.toString() ?? '') ?? 0,
    height:
        responses[2] is double
            ? responses[2]
            : double.tryParse(responses[2]?.toString() ?? '') ?? 0.0,
    weight:
        responses[3] is double
            ? responses[3]
            : double.tryParse(responses[3]?.toString() ?? '') ?? 0.0,
    activityLevel: safeString(responses[4]),
    dietaryPreferences: safeString(responses[5]),
    foodAllergies: safeString(responses[6]),
    goal: safeString(responses[7]),
    mealsPerDay: safeString(responses[8]),
    glassesOfWater: safeString(responses[9]),
  );
}

// Provider for the ViewModel
final surveyViewModelProvider =
    StateNotifierProvider<SurveyViewModel, SurveyState>((ref) {
      final repository = SurveyRepositories();
      final useCase = SurveyUsecase(repository);
      return SurveyViewModel(useCase);
    });
