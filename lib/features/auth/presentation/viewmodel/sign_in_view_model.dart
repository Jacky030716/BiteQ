import 'package:biteq/core/navigation/app_router.dart';
import 'package:biteq/features/auth/domain/usecases/sign_in_usecase.dart';
import 'package:biteq/features/survey_form/data/repositories/survey_repositories.dart';
import 'package:biteq/features/survey_form/domain/usecase/survey_usecase.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/user.dart';
import '../../data/repositories/auth_repository.dart';

class SignInViewModel extends StateNotifier<AsyncValue<User?>> {
  final SignInUsecase signInUsecase;
  final SurveyUsecase surveyUsecase;

  String _email = '';
  String _password = '';
  String? emailError;
  String? passwordError;

  SignInViewModel(this.signInUsecase, this.surveyUsecase)
    : super(const AsyncValue.data(null));

  void setEmail(String email) {
    _email = email.trim();

    if (_email.isEmpty) {
      emailError = 'Email cannot be empty';
    } else if (!validateEmail(_email)) {
      emailError = 'Please enter a valid email address';
    } else {
      emailError = null;
    }

    // Clear error state when input changes
    if (state is AsyncError) {
      state = const AsyncValue.data(null);
    } else {
      state = state;
    }
  }

  void setPassword(String password) {
    _password = password.trim();

    if (_password.isEmpty) {
      passwordError = 'Password cannot be empty';
    } else if (!validatePassword(_password)) {
      passwordError =
          'Password must contain at least 8 characters, 1 uppercase letter, 1 lowercase letter, and 1 number';
    } else {
      passwordError = null;
    }

    // Clear error state when input changes
    if (state is AsyncError) {
      state = const AsyncValue.data(null);
    } else {
      state = state;
    }
  }

  bool validateEmail(String email) {
    final emailRegex = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
    return emailRegex.hasMatch(email);
  }

  bool validatePassword(String password) {
    final passwordRegex = RegExp(
      r'^(?=.*?[A-Z])(?=.*?[a-z])(?=.*?[0-9]).{8,}$',
    );
    return passwordRegex.hasMatch(password);
  }

  Future<void> signIn(Function onSuccess, WidgetRef ref) async {
    setEmail(_email);
    setPassword(_password);

    if (emailError != null || passwordError != null) {
      throw Exception('Invalid input');
    }

    state = const AsyncValue.loading();
    try {
      final user = await signInUsecase.signIn(_email, _password);
      state = AsyncValue.data(user);

      ref.invalidate(authStateProvider);

      onSuccess();
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
    }
  }

  Future<bool> isSurveyCompleted() async {
    try {
      final isCompleted = await surveyUsecase.getSurveyStatus(_email);

      return isCompleted;
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
      return false;
    }
  }

  Future<void> signInWithGoogle(Function onSuccess, WidgetRef ref) async {
    state = const AsyncValue.loading();
    try {
      await signInUsecase.signInWithGoogle();
      state = AsyncValue.data(null);

      ref.invalidate(authStateProvider);

      onSuccess();
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
    }
  }

  // Reset state to initial data
  void resetError() {
    if (state is AsyncError) {
      state = const AsyncValue.data(null);
    }
  }
}

// Provider for the ViewModel
final signInViewModelProvider =
    StateNotifierProvider<SignInViewModel, AsyncValue<User?>>((ref) {
      final repository = AuthRepository();
      final surveyRepository = SurveyRepositories();

      final useCase = SignInUsecase(repository);
      final surveyUseCase = SurveyUsecase(surveyRepository);

      return SignInViewModel(useCase, surveyUseCase);
    });
