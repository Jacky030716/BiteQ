import 'package:flutter/material.dart';
import 'package:biteq/features/auth/presentation/viewmodel/sign_out_view_model.dart';
import 'package:biteq/features/profile/presentation/profile_header.dart';
import 'package:biteq/features/profile/presentation/profile_info_card.dart';
import 'package:biteq/features/profile/presentation/survey_summary_card.dart';
import 'package:flutter/services.dart';
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
        actions: [
          IconButton(
            icon: Icon(Icons.logout_outlined, color: Colors.red.shade600),
            onPressed: () {
              signOutViewModel.signOut(() {
                ref.invalidate(userProfileViewModelProvider);
                context.go('/sign-in');
              }, ref);
            },
          ),
        ],
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
                      title: 'General',
                      items: [
                        ProfileInfoItem(
                          icon: Icons.person_outline,
                          text: 'Personal Information',
                          onTap: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: const Text('Personal Info tapped!'),
                                backgroundColor: Colors.blue.shade400,
                                behavior: SnackBarBehavior.floating,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                            );
                          },
                        ),
                        if (user.aiAnalysisNotes == null ||
                            user.aiAnalysisNotes!.isEmpty)
                          ProfileInfoItem(
                            icon: Icons.auto_awesome, // AI icon
                            text: 'Generate AI Analysis',
                            onTap: () async {
                              // Show loading indicator or disable button while generating
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: const Text(
                                    'Generating AI Analysis...',
                                  ),
                                  backgroundColor: Colors.blue.shade400,
                                  behavior: SnackBarBehavior.floating,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                              );
                              await ref
                                  .read(userProfileViewModelProvider.notifier)
                                  .generateAndSaveAiAnalysis();
                              // After generation, the UI will rebuild with the updated notes
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: const Text('AI Analysis Generated!'),
                                  backgroundColor: Colors.green.shade400,
                                  behavior: SnackBarBehavior.floating,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                              );
                            },
                          )
                        else
                          ProfileInfoItem(
                            icon: Icons.analytics_outlined, // Analysis icon
                            text: 'View AI Analysis',
                            onTap: () {
                              _showAiAnalysisDialog(
                                context,
                                user.aiAnalysisNotes!,
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

void _showAiAnalysisDialog(BuildContext context, String notes) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return Dialog(
        // Using Dialog for more control over shape and margin
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ), // More rounded corners
        elevation: 10, // Add some elevation for a lifted effect
        backgroundColor: Colors.white,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 24.0,
            vertical: 20.0,
          ), // Overall dialog padding
          child: Column(
            mainAxisSize: MainAxisSize.min, // Make column take minimum space
            crossAxisAlignment:
                CrossAxisAlignment.start, // Align content to the left
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    // Use Expanded to prevent overflow if title is long
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.auto_awesome,
                          color: Colors.blue.shade600,
                          size: 28,
                        ), // Slightly larger icon
                        const SizedBox(width: 12), // More space
                        Flexible(
                          // Ensure title wraps if too long
                          child: Text(
                            'Your Personalized AI Analysis', // More descriptive title
                            style: Theme.of(
                              context,
                            ).textTheme.headlineSmall?.copyWith(
                              fontSize: 20,
                              fontWeight: FontWeight.w700, // Even bolder
                              color: Colors.black87,
                              height: 1.2, // Adjust line height
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    // Add a clear close button
                    icon: const Icon(Icons.close, color: Colors.grey),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  ),
                ],
              ),
              const SizedBox(height: 16), // Space between title and content
              // Content section
              Flexible(
                // Make content scrollable if it gets too long
                child: SingleChildScrollView(
                  child: Text(
                    notes,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: Colors.black87,
                      height:
                          1.5, // Increased line height for better readability
                      fontSize: 16, // Slightly larger font size for content
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 24), // Space between content and actions
              // Actions buttons
              Row(
                mainAxisAlignment:
                    MainAxisAlignment.end, // Align actions to the right
                children: <Widget>[
                  TextButton.icon(
                    onPressed: () {
                      Clipboard.setData(ClipboardData(text: notes)).then((_) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: const Text(
                              'Analysis copied to clipboard!',
                            ),
                            backgroundColor: Colors.green.shade400,
                            behavior: SnackBarBehavior.floating,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            margin: const EdgeInsets.all(10),
                          ),
                        );
                      });
                      // Navigator.of(context).pop(); // Optionally close after copy
                    },
                    icon: Icon(Icons.copy, color: Colors.blue.shade600),
                    label: Text(
                      'Copy',
                      style: TextStyle(color: Colors.blue.shade600),
                    ),
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 10,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    // Use ElevatedButton for the primary action
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          Colors.blue.shade600, // Primary action color
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 12,
                      ),
                      elevation: 3,
                    ),
                    child: const Text(
                      'Done', // More conclusive text
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    },
  );
}
