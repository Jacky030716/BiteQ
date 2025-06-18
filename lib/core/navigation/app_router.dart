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
import 'package:biteq/features/posting/create_post_page.dart';
import 'package:biteq/features/posting/explore_page.dart';
import 'package:biteq/features/posting/post_controller.dart';
import 'package:biteq/features/posting/post_detail_page.dart';
import 'package:biteq/features/profile/presentation/user_profile_page.dart';
import 'package:biteq/features/survey_form/data/repositories/survey_repositories.dart';
import 'package:biteq/features/survey_form/presentation/pages/survey_page.dart';
import 'package:biteq/main_navigation_wrapper.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class AppRouter {
  final PostController postController;
  final AuthRepository authRepository;
  final SurveyRepositories surveyRepositories;

  AppRouter({
    required this.postController,
    required this.authRepository,
    required this.surveyRepositories,
  });

  late final redirectService = RedirectService(
    authRepository: authRepository,
    surveyRepositories: surveyRepositories,
  );

  late final router = GoRouter(
    initialLocation: '/home',
    routes: [
      // Auth Routes
      GoRoute(
        path: '/sign-up',
        builder: (context, state) => const SignUpScreen(),
      ),
      GoRoute(
        path: '/sign-in',
        builder: (context, state) => const SignInScreen(),
      ),
      // ... other auth routes

      // Main Navigation Shell
      ShellRoute(
        builder:
            (context, state, child) =>
                MainNavigationWrapper(postController: postController),
        routes: [
          GoRoute(
            path: '/home',
            builder: (context, state) => const HomeScreen(),
          ),
          GoRoute(
            path: '/explore',
            builder:
                (context, state) => ExplorePage(postController: postController),
          ),
          // ... other shell routes
        ],
      ),

      // Posting Routes
      GoRoute(
        path: '/create-post',
        builder:
            (context, state) => CreatePostPage(postController: postController),
      ),
      GoRoute(
        path: '/post-detail',
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>;
          return PostDetailPage(
            post: extra['post'],
            postIndex: extra['postIndex'],
            postController: extra['postController'],
          );
        },
      ),
    ],
    errorBuilder:
        (context, state) => Scaffold(
          body: Center(child: Text('Route not found: ${state.uri.toString()}')),
        ),
  );
}
