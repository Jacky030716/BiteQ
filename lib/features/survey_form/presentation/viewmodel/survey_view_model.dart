import 'package:biteq/features/survey_form/data/questions.dart';
import 'package:biteq/features/survey_form/data/repositories/survey_repositories.dart';
import 'package:biteq/features/survey_form/domain/usecase/survey_usecase.dart';
import 'package:biteq/features/survey_form/domain/utils/survey_validation.dart';
import 'package:biteq/features/survey_form/domain/utils/survey_mapping.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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
        SurveyState(responses: List.generate(questions.length, (_) => '')),
      ) {
    inputController.addListener(_handleTextInputChange);
  }

  bool get isFirstQuestion => state.currentQuestionIndex == 0;
  bool get isLastQuestion => state.currentQuestionIndex == questions.length - 1;
  Map<String, dynamic> get currentQuestion =>
      questions[state.currentQuestionIndex];

  void _handleTextInputChange() {
    if (currentQuestion['type'] == 'input' ||
        currentQuestion['type'] == 'scrollable_input') {
      final text = inputController.text;

      if (text.isNotEmpty) {
        final validation = currentQuestion['validation'];
        final error = SurveyValidation.validateInput(text, validation);
        if (error == null) {
          final value =
              currentQuestion['type'] == 'scrollable_input'
                  ? int.tryParse(text)
                  : text;
          _updateResponse(value);
          state = state.copyWith(clearErrorMessage: true);
        } else {
          state = state.copyWith(errorMessage: error);
        }
      }
    }
  }

  void _updateResponse(dynamic value) {
    if (value == null) return;

    final responses = List<dynamic>.from(state.responses);
    responses[state.currentQuestionIndex] = value;
    state = state.copyWith(responses: responses, clearErrorMessage: true);
  }

  void selectOption(int index) {
    final selectedValue = currentQuestion['options'][index];
    state = state.copyWith(selectedOption: index, clearErrorMessage: true);
    _updateResponse(selectedValue);
  }

  bool validateCurrentResponse() {
    if (currentQuestion['type'] == 'options') {
      if (state.selectedOption == null) {
        state = state.copyWith(errorMessage: 'Please select an option');
        return false;
      }
    } else if (currentQuestion['type'] == 'input') {
      final text = inputController.text;
      final validation = currentQuestion['validation'];

      if (text.isEmpty) {
        state = state.copyWith(errorMessage: 'Please enter a value');
        return false;
      }

      final error = SurveyValidation.validateInput(text, validation);
      if (error != null) {
        state = state.copyWith(errorMessage: error);
        return false;
      }
    }
    return true;
  }

  bool moveToNextQuestion() {
    if (!validateCurrentResponse()) {
      return false;
    }

    if (state.currentQuestionIndex < questions.length - 1) {
      state = state.copyWith(
        currentQuestionIndex: state.currentQuestionIndex + 1,
        clearSelectedOption: true,
        clearErrorMessage: true,
      );
      _prepareCurrentQuestion();
    }
    return true;
  }

  void moveToPreviousQuestion() {
    if (state.currentQuestionIndex > 0) {
      state = state.copyWith(
        currentQuestionIndex: state.currentQuestionIndex - 1,
        clearErrorMessage: true,
      );
      _prepareCurrentQuestion();
    }
  }

  void _prepareCurrentQuestion() {
    final response = state.responses[state.currentQuestionIndex];

    if (currentQuestion['type'] == 'options' && response is int) {
      state = state.copyWith(selectedOption: response);
    } else if (currentQuestion['type'] == 'input' ||
        currentQuestion['type'] == 'scrollable_input') {
      inputController.text = response?.toString() ?? '';
    }
  }

  Future<void> submitSurvey(Function onSuccess) async {
    if (!validateCurrentResponse()) {
      return;
    }

    state = state.copyWith(isSubmitting: true);
    try {
      final survey = mapResponsesToUserSurvey(state.responses);
      await useCase.submitSurvey(survey);

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

// Provider for the ViewModel
final surveyViewModelProvider =
    StateNotifierProvider<SurveyViewModel, SurveyState>((ref) {
      final repository = SurveyRepositories();
      final useCase = SurveyUsecase(repository);
      return SurveyViewModel(useCase);
    });
