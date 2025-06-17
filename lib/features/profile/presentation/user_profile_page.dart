import 'package:biteq/features/profile/presentation/ai_analysis_dialog.dart';
import 'package:flutter/material.dart';
import 'package:biteq/features/auth/presentation/viewmodel/sign_out_view_model.dart';
import 'package:biteq/features/profile/presentation/profile_header.dart';
import 'package:biteq/features/profile/presentation/profile_info_card.dart';
import 'package:biteq/features/profile/presentation/survey_summary_card.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:biteq/features/profile/viewmodels/user_profile_view_model.dart';
import 'package:go_router/go_router.dart';

class UserProfileScreen extends ConsumerWidget {
  const UserProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userProfileAsyncValue = ref.watch(userProfileViewModelProvider);
    final signOutViewModel = ref.read(signOutViewModelProvider.notifier);

    return Scaffold(
      backgroundColor: Colors.grey.shade50, // Consistent background color
      appBar: AppBar(
        title: const Text(
          'Profile',
          style: TextStyle(color: Colors.black87, fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0.5,
        shadowColor: Colors.black.withOpacity(0.1),
      ),
      body: userProfileAsyncValue.when(
        loading:
            () => Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.blue.shade600),
              ),
            ),
        error:
            (error, stackTrace) => Center(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.error_outline,
                      color: Colors.red.shade400,
                      size: 64,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Error loading profile',
                      style: Theme.of(
                        context,
                      ).textTheme.headlineSmall?.copyWith(
                        color: Colors.black87,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      error.toString(),
                      textAlign: TextAlign.center,
                      style: Theme.of(
                        context,
                      ).textTheme.bodyMedium?.copyWith(color: Colors.black54),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed:
                          () =>
                              ref
                                  .read(userProfileViewModelProvider.notifier)
                                  .refreshUserProfile(),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue.shade600,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 12,
                        ),
                      ),
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              ),
            ),
        data: (user) {
          // Check if AI analysis is currently generating to show a loading state
          final isGeneratingAnalysis =
              user.aiAnalysisNotes == 'Generating analysis...';

          return RefreshIndicator(
            onRefresh:
                () =>
                    ref
                        .read(userProfileViewModelProvider.notifier)
                        .refreshUserProfile(),
            color: Colors.blue.shade600,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    ProfileHeader(
                      name: user.name,
                      email: user.email,
                      profileImageUrl: user.profileImageUrl,
                    ),
                    const SizedBox(height: 24),
                    SurveySummaryCard(surveyResponses: user.surveyResponses),
                    const SizedBox(height: 24),
                    ProfileInfoCard(
                      title: 'AI Insights & Security', // Updated title
                      items: [
                        // Conditional rendering for AI Analysis
                        if (user.aiAnalysisNotes == null ||
                            user.aiAnalysisNotes!.isEmpty ||
                            isGeneratingAnalysis)
                          ProfileInfoItem(
                            icon:
                                isGeneratingAnalysis
                                    ? Icons.hourglass_empty
                                    : Icons
                                        .auto_awesome, // AI icon / loading icon
                            text:
                                isGeneratingAnalysis
                                    ? 'Generating AI Analysis...'
                                    : 'Generate AI Analysis',
                            onTap:
                                isGeneratingAnalysis
                                    ? null
                                    : () async {
                                      // Disable button while generating
                                      // Show loading indicator or disable button while generating
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        SnackBar(
                                          content: Text(
                                            isGeneratingAnalysis
                                                ? 'Still generating...'
                                                : 'Generating AI Analysis...',
                                          ),
                                          backgroundColor: Colors.blue.shade400,
                                          behavior: SnackBarBehavior.floating,
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                              10,
                                            ),
                                          ),
                                        ),
                                      );
                                      await ref
                                          .read(
                                            userProfileViewModelProvider
                                                .notifier,
                                          )
                                          .generateAndSaveAiAnalysis();
                                      // After generation, the UI will rebuild with the updated notes
                                      // SnackBar for success will be handled by the VM or by the _loadUserProfile completing
                                    },
                          )
                        else
                          ProfileInfoItem(
                            icon: Icons.analytics_outlined, // Analysis icon
                            text: 'View AI Analysis & Macros', // Updated text
                            onTap: () {
                              // Call the extracted dialog function
                              showAiAnalysisDialog(
                                context,
                                user.aiAnalysisNotes!,
                                user.recommendedProtein,
                                user.recommendedCarbs,
                                user.recommendedFat,
                                user.recommendedCalories,
                              );
                            },
                          ),
                        ProfileInfoItem(
                          icon: Icons.vpn_key_outlined,
                          text: 'Password & Security',
                          onTap: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: const Text(
                                  'Password & Security tapped!',
                                ),
                                backgroundColor: Colors.blue.shade400,
                                behavior: SnackBarBehavior.floating,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                            );
                          },
                        ),
                        ProfileInfoItem(
                          icon: Icons.logout,
                          text: "Log Out",
                          onTap: () {
                            signOutViewModel.signOut(() {
                              ref.invalidate(userProfileViewModelProvider);
                              context.go('/sign-in');
                            }, ref);
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
