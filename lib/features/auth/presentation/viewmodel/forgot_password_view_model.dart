import 'package:biteq/features/auth/domain/usecases/forgot_password_usecase.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/user.dart';
import '../../data/repositories/auth_repository.dart';

class ForgotPasswordViewModel extends StateNotifier<AsyncValue<User?>> {
  final ForgotPasswordUsecase forgotPasswordUsecase;

  String _email = '';
  String? emailError;

  ForgotPasswordViewModel(this.forgotPasswordUsecase)
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

  bool validateEmail(String email) {
    final emailRegex = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
    return emailRegex.hasMatch(email);
  }

  Future<void> resetPassword(Function onSuccess) async {
    setEmail(_email);

    if (emailError != null) {
      throw Exception('Invalid input');
    }

    state = const AsyncValue.loading();
    try {
      final user = await forgotPasswordUsecase.execute(_email);
      state = AsyncValue.data(user);

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
final forgotPasswordViewModelProvider =
    StateNotifierProvider<ForgotPasswordViewModel, AsyncValue<User?>>((ref) {
      final repository = AuthRepository();
      final useCase = ForgotPasswordUsecase(repository);
      return ForgotPasswordViewModel(useCase);
    });
