import 'package:biteq/features/auth/data/models/user_model.dart';
import 'package:biteq/features/auth/data/repositories/auth_repository.dart';
import 'package:biteq/features/survey_form/data/repositories/survey_repositories.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class RedirectService {
  final AuthRepository authRepository;
  final SurveyRepositories surveyRepositories;

  RedirectService({
    required this.authRepository,
    required this.surveyRepositories,
  });

  Future<String?> handleRedirect(
    AsyncValue<UserModel?> authState,
    String matchedLocation,
  ) async {
    final publicRoutes = [
      '/sign-in',
      '/sign-up',
      '/onboarding',
      '/forgot-password',
    ];

    if (authState.isLoading) {
      return null;
    }

    final isLoggedIn = authState.value != null;

    // Handle public routes
    if (!isLoggedIn && publicRoutes.contains(matchedLocation)) {
      return null;
    }

    // Redirect unauthenticated users
    if (!isLoggedIn) {
      final hasDisplayedOnboarding =
          await authRepository.hasDisplayedOnboarding();

      if (!hasDisplayedOnboarding) {
        return '/onboarding';
      } else {
        return '/sign-in';
      }
    }

    if (isLoggedIn && matchedLocation == '/') {
      return '/home';
    }

    if (isLoggedIn) {
      final isSurveyCompleted = await surveyRepositories.getSurveyStatus(
        authState.value!.email,
      );

      if (!isSurveyCompleted) {
        return '/survey';
      } else {
        return null;
      }
    }

    return null;
  }
}
