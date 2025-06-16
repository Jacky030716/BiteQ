import 'package:biteq/features/profile/entities/profile_user.dart';
import 'package:biteq/features/profile/repositories/user_repository.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_gemini/flutter_gemini.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Provides the UserProfileViewModel
final userProfileViewModelProvider =
    StateNotifierProvider<UserProfileViewModel, AsyncValue<ProfileUser>>((ref) {
      // Use ProfileUser here
      return UserProfileViewModel(ref.read(userRepositoryProvider));
    });

// Provides the UserRepository instance
final userRepositoryProvider = Provider((ref) => UserRepository());

class UserProfileViewModel extends StateNotifier<AsyncValue<ProfileUser>> {
  // Use ProfileUser here
  final UserRepository _userRepository;

  UserProfileViewModel(this._userRepository)
    : super(const AsyncValue.loading()) {
    _loadUserProfile();
  }

  // Loads the user profile data
  Future<void> _loadUserProfile() async {
    try {
      state = const AsyncValue.loading();
      final user = await _userRepository.fetchUserProfile();
      state = AsyncValue.data(user);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> generateAndSaveAiAnalysis() async {
    if (state is AsyncData<ProfileUser>) {
      final currentUser = state.value!; // Get current user data
      final firebaseUser =
          FirebaseAuth.instance.currentUser; // Get current Firebase user

      if (firebaseUser == null) {
        state = AsyncValue.error(
          'User not logged in for AI analysis.',
          StackTrace.current,
        );
        return;
      }

      state = AsyncValue.data(
        currentUser.copyWith(aiAnalysisNotes: 'Generating analysis...'),
      ); // Optional: show a temporary message

      try {
        final survey = currentUser.surveyResponses;
        final prompt = """
      Analyze the following user profile data and provide a comprehensive, actionable health and nutrition analysis in a friendly tone. Focus on dietary preferences, activity level, and goals, and suggest improvements or affirmations related to water intake and meal frequency.

      User Name: ${currentUser.name}
      Activity Level: ${survey.activityLevel}
      Age: ${survey.age}
      Dietary Preferences: ${survey.dietaryPreferences}
      Food Allergies: ${survey.foodAllergies}
      Gender: ${survey.gender}
      Glasses of Water per day: ${survey.glassesOfWater}
      Goal: ${survey.goal}
      Height: ${survey.height.toInt()} cm
      Meals per day: ${survey.mealsPerDay}

      Based on this, offer personalized insights and recommendations for their diet and hydration. Keep the analysis concise, around 150-200 words, and encouraging.
      """;

        // Call Gemini API
        final gemini = Gemini.instance;
        final response = await gemini.text(prompt);

        print('AI Analysis Response: ${response?.output}');

        final generatedNotes =
            response?.output ??
            'Failed to generate analysis. Please try again.';

        // Update Firestore using the actual user UID
        await _userRepository.updateAiAnalysisNotes(
          firebaseUser.uid, // Use Firebase UID as the document ID
          generatedNotes,
        );

        // After updating Firestore, refresh the user profile to get the latest data
        await _loadUserProfile();
      } catch (e, st) {
        state = AsyncValue.error(
          'Error generating or saving AI analysis: $e',
          st,
        );
      }
    }
  }

  // Allows manual refresh of the user profile
  Future<void> refreshUserProfile() async {
    await _loadUserProfile();
  }
}

extension ProfileUserCopyWith on ProfileUser {
  ProfileUser copyWith({
    String? email,
    String? name,
    String? profileImageUrl,
    SurveyResponses? surveyResponses,
    String? aiAnalysisNotes,
    bool? isLoadingAiAnalysis, // Add this for UI state, not for database
  }) {
    return ProfileUser(
      email: email ?? this.email,
      name: name ?? this.name,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      surveyResponses: surveyResponses ?? this.surveyResponses,
      aiAnalysisNotes: aiAnalysisNotes ?? this.aiAnalysisNotes,
    );
  }
}
