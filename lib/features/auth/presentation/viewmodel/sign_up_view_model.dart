import 'package:biteq/core/navigation/app_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/user.dart';
import '../../data/repositories/auth_repository.dart';
import '../../domain/usecases/sign_up_usecase.dart';

class SignUpViewModel extends StateNotifier<AsyncValue<User?>> {
  final SignUpUseCase signUpUseCase;

  String _email = '';
  String _username = '';
  String _password = '';
  String? emailError;
  String? usernameError;
  String? passwordError;

  SignUpViewModel(this.signUpUseCase) : super(const AsyncValue.data(null));

  void setEmail(String email) {
    _email = email.trim();

    if (_email.isEmpty) {
      emailError = 'Email cannot be empty';
    } else if (!validateEmail(_email)) {
      emailError = 'Please enter a valid email address';
    } else {
      emailError = null;
    }

    if (state is AsyncError) {
      state = const AsyncValue.data(null);
    } else {
      state = state;
    }
  }

  void setUsername(String username) {
    _username = username.trim();

    if (_username.isEmpty) {
      usernameError = 'Username cannot be empty';
    } else if (_username.length < 3) {
      usernameError = 'Username must be at least 3 characters long';
    } else {
      usernameError = null;
    }

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

  Future<void> signUp(Function onSuccess, WidgetRef ref) async {
    setEmail(_email);
    setUsername(_username);
    setPassword(_password);

    // Check if there are any validation errors
    if (emailError != null || usernameError != null || passwordError != null) {
      return;
    }

    state = const AsyncValue.loading();
    try {
      final user = await signUpUseCase.execute(_email, _username, _password);
      state = AsyncValue.data(user);

      ref.invalidate(authStateProvider);

      onSuccess();
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
    }
  }
}

// Provider for the ViewModel
final signUpViewModelProvider =
    StateNotifierProvider<SignUpViewModel, AsyncValue<User?>>((ref) {
      final repository = AuthRepository();
      final useCase = SignUpUseCase(repository);
      return SignUpViewModel(useCase);
    });
