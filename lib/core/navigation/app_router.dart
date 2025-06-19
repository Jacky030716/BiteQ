import 'package:biteq/core/services/redirect_services.dart';
import 'package:biteq/features/ai_detection/presentation/pages/image_picker_page.dart';

import 'package:biteq/features/auth/data/models/user_model.dart';
import 'package:biteq/features/auth/data/repositories/auth_repository.dart';
import 'package:biteq/features/auth/presentation/pages/change_password_screen.dart';
import 'package:biteq/features/auth/presentation/pages/forgot_password_screen.dart';
import 'package:biteq/features/auth/presentation/pages/sign_in_screen.dart';
import 'package:biteq/features/auth/presentation/pages/sign_up_screen.dart';
import 'package:biteq/features/food_analysis/presentation/pages/food_analysis_page.dart';
import 'package:biteq/features/home_dashboard/presentation/pages/home_screen.dart';
import 'package:biteq/features/onboarding/presentation/pages/onboarding_page.dart';
import 'package:biteq/features/profile/presentation/user_profile_page.dart';
import 'package:biteq/features/survey_form/data/repositories/survey_repositories.dart';
import 'package:biteq/features/survey_form/presentation/pages/survey_page.dart';
import 'package:biteq/main_navigation_wrapper.dart';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:biteq/features/posting/explore_page.dart';
import 'package:biteq/features/posting/create_post_page.dart';
import 'package:biteq/features/posting/providers/post_providers.dart';
import 'package:biteq/features/posting/post_detail_page.dart';
import 'package:biteq/features/posting/post_controller.dart';

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
  final redirectService = ref.read(redirectServiceProvider);

  // Create a router notifier to handle auth state changes more efficiently
  final routerNotifier = RouterNotifier(ref);

  return GoRouter(
    initialLocation: '/home',
    refreshListenable:
        routerNotifier, // Use the notifier as the refresh listener
    redirect: (context, state) async {
      final authState = ref.read(authStateProvider);
      return await redirectService.handleRedirect(
        authState,
        state.matchedLocation,
      );
    },
    routes: [
      GoRoute(
        path: '/sign-up',
        builder: (context, state) => const SignUpScreen(),
      ),
      GoRoute(
        path: '/sign-in',
        builder: (context, state) => const SignInScreen(),
      ),
      GoRoute(
        path: '/onboarding',
        builder: (context, state) => const OnboardingPage(),
      ),
      GoRoute(
        path: '/forgot-password',
        builder: (context, state) => const ForgotPasswordScreen(),
      ),
      GoRoute(path: '/survey', builder: (context, state) => const SurveyPage()),
      GoRoute(
        path: '/change-password',
        builder: (context, state) => const ChangePasswordScreen(),
      ),
      GoRoute(
        path: '/create-post',
        builder: (context, state) => const CreatePostPage(),
      ),
      GoRoute(
        path: '/post/:id',
        builder: (context, state) {
          final postId = state.pathParameters['id']!;
          return PostDetailPage(postId: postId);
        },
      ),
      ShellRoute(
        builder: (context, state, child) {
          return const MainNavigationWrapper();
        },
        routes: [
          GoRoute(
            path: '/home',
            builder: (context, state) => const HomeScreen(),
          ),
          GoRoute(
            path: '/explore',
            builder: (context, state) => const ExplorePage(),
          ),
          GoRoute(
            path: '/ai_detection', // Assuming this is your camera/AI page
            builder: (context, state) => const ImagePickerPage(),
          ),
          GoRoute(
            path: '/food-analysis', // Add your FoodAnalysisPage if it's a tab
            builder: (context, state) => const FoodAnalysisPage(),
          ),
          GoRoute(
            path: '/profile',
            builder: (context, state) => const UserProfileScreen(),
          ),
          // Add other main navigation routes here
        ],
      ),
    ],
    errorBuilder:
        (context, state) => Scaffold(
          body: Center(child: Text('Route not found: ${state.uri.toString()}')),
        ),
  );
});

// Create a RouterNotifier class that extends ChangeNotifier
class RouterNotifier extends ChangeNotifier {
  final Ref _ref;

  RouterNotifier(this._ref) {
    // Only notify listeners when the auth state actually changes (not during loading)
    _ref.listen<AsyncValue<UserModel?>>(authStateProvider, (_, next) {
      // Only notify if data is available (not during loading state)
      if (!next.isLoading) {
        notifyListeners();
      }
    });
  }
}
