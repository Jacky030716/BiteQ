import 'package:biteq/core/services/redirect_services.dart';
import 'package:biteq/core/widgets/splash_screen.dart';
import 'package:biteq/features/home_dashboard/presentation/pages/home_screen.dart';

import 'package:biteq/features/auth/data/models/user_model.dart';
import 'package:biteq/features/auth/data/repositories/auth_repository.dart';
import 'package:biteq/features/auth/presentation/pages/forgot_password_screen.dart';
import 'package:biteq/features/auth/presentation/pages/sign_in_screen.dart';
import 'package:biteq/features/auth/presentation/pages/sign_up_screen.dart';
import 'package:biteq/features/onboarding/presentation/pages/onboarding_page.dart';
import 'package:biteq/features/survey_form/data/repositories/survey_repositories.dart';
import 'package:biteq/features/survey_form/presentation/pages/survey_page.dart';

import 'package:biteq/features/posting/explore_page.dart';
import 'package:biteq/features/posting/create_post_page.dart';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

// Provider for Auth Repository
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository();
});

final surveyRepositoriesProvider = Provider<SurveyRepositories>((ref) {
  return SurveyRepositories();
});

final redirectServiceProvider = Provider<RedirectService>((ref) {
  final authRepository = ref.read(authRepositoryProvider);
  final surveyRepositories = ref.read(surveyRepositoriesProvider);

  return RedirectService(
    authRepository: authRepository,
    surveyRepositories: surveyRepositories,
  );
});

// Provider for User Authentication State
final authStateProvider = FutureProvider<UserModel?>((ref) async {
  final authRepository = ref.read(authRepositoryProvider);
  final user = await authRepository.attemptAutoLogin();

  return user;
});

final routerProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authStateProvider);
  final redirectService = ref.read(redirectServiceProvider);

  return GoRouter(
    initialLocation: '/survey',
    redirect: (context, state) async {
      return await redirectService.handleRedirect(
        authState,
        state.matchedLocation,
      );
    },
    routes: [
      GoRoute(path: '/home', builder: (context, state) => const HomeScreen()),
      GoRoute(
        path: '/sign-up',
        builder: (context, state) => const SignUpScreen(),
      ),
      GoRoute(
        path: '/sign-in',
        builder: (context, state) => const SignInScreen(),
      ),
      GoRoute(path: '/', builder: (context, state) => const SplashScreen()),
      GoRoute(
        path: '/onboarding',
        builder: (context, state) => const OnboardingPage(),
      ),
      GoRoute(
        path: '/forgot-password',
        builder: (context, state) => const ForgotPasswordScreen(),
      ),
      GoRoute(
        path: '/survey',
        builder: (context, state) {
          return const SurveyPage(); // Replace with your survey screen
        },
      ),
      GoRoute(
        path: '/explore',
        builder: (context, state) => const ExplorePage(),
      ),
      GoRoute(
        path: '/create-post',
        builder: (context, state) => const CreatePostPage(),
      ),
    ],
    errorBuilder:
        (context, state) => Scaffold(
          body: Center(child: Text('Route not found: ${state.uri.toString()}')),
        ),
  );
});
