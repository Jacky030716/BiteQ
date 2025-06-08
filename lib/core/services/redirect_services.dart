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
    // Define public routes
    const publicRoutes = [
      '/sign-in',
      '/sign-up',
      '/onboarding',
      '/forgot-password',
    ];

    // Handle loading state
    if (authState.isLoading) {
      return null;
    }

    // Check authentication status
    final isLoggedIn = authState.value != null;

    // Handle unauthenticated users
    if (!isLoggedIn) {
      if (publicRoutes.contains(matchedLocation)) {
        return null; // Allow access to public routes
      }

      final hasDisplayedOnboarding =
          await authRepository.hasDisplayedOnboarding();

      return hasDisplayedOnboarding ? '/sign-in' : '/onboarding';
    }

    // Handle authenticated users
    final isSurveyCompleted = await surveyRepositories.getSurveyStatus(
      authState.value!.email,
    );

    if (matchedLocation == '/') {
      return isSurveyCompleted ? '/home' : '/survey';
    }

    return null;
  }
}
