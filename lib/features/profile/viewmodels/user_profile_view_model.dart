import 'package:biteq/features/profile/entities/profile_user.dart';
import 'package:biteq/features/profile/repositories/user_repository.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_gemini/flutter_gemini.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:convert'; // For JSON decoding

// Provides the UserProfileViewModel
final userProfileViewModelProvider =
    StateNotifierProvider<UserProfileViewModel, AsyncValue<ProfileUser>>((ref) {
      return UserProfileViewModel(ref.read(userRepositoryProvider));
    });

// Provides the UserRepository instance
final userRepositoryProvider = Provider((ref) => UserRepository());

class UserProfileViewModel extends StateNotifier<AsyncValue<ProfileUser>> {
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

  // Generates and saves AI analysis and macronutrient recommendations
  Future<void> generateAndSaveAiAnalysis() async {
    if (state is! AsyncData<ProfileUser>) {
      // If data is not loaded or is in an error state, cannot proceed
      return;
    }

    final currentUser = state.value!;
    final firebaseUser = FirebaseAuth.instance.currentUser;

    if (firebaseUser == null) {
      state = AsyncValue.error(
        'User not logged in for AI analysis.',
        StackTrace.current,
      );
      return;
    }

    // Set a temporary loading state for AI analysis notes
    state = AsyncValue.data(
      currentUser.copyWith(
        aiAnalysisNotes: 'Generating analysis...',
        recommendedProtein: null,
        recommendedCarbs: null,
        recommendedFat: null,
        recommendedCalories: null,
      ),
    );

    try {
      final survey = currentUser.surveyResponses;
      // Enhanced prompt to ask for both general analysis and structured macro recommendations
      final prompt = """
        As a professional nutritionist, analyze this user's profile and provide exactly two things:

        First, write a personalized health analysis (50-75 words) using "you" and "your". Cover their dietary habits, activity level, and goal-specific recommendations without jargon.

        Second, provide daily macro recommendations as a raw JSON object (no code blocks, no backticks): {'recommended_protein': X, 'recommended_carbs': Y, 'recommended_fat': Z, 'recommended_calories': W}

        Profile:
        - Name: ${currentUser.name}
        - Age: ${survey.age}, Gender: ${survey.gender}  
        - Height: ${survey.height.toInt()}cm
        - Goal: ${survey.goal}
        - Activity: ${survey.activityLevel}
        - Diet: ${survey.dietaryPreferences}
        - Allergies: ${survey.foodAllergies}
        - Water: ${survey.glassesOfWater} glasses/day
        - Meals: ${survey.mealsPerDay}/day
        """;

      // Call Gemini API
      final gemini = Gemini.instance;
      final response = await gemini.text(prompt);

      final fullResponse =
          response?.output ?? 'Failed to generate analysis. Please try again.';

      String generatedNotes;
      int? recProtein, recCarbs, recFat, recCalories;

      // Attempt to parse the structured JSON from the response
      try {
        final jsonStartIndex = fullResponse.indexOf('{');
        final jsonEndIndex = fullResponse.lastIndexOf('}');

        if (jsonStartIndex != -1 &&
            jsonEndIndex != -1 &&
            jsonEndIndex > jsonStartIndex) {
          final jsonString = fullResponse.substring(
            jsonStartIndex,
            jsonEndIndex + 1,
          );
          final Map<String, dynamic> parsedJson = json.decode(jsonString);

          recProtein = parsedJson['recommended_protein'] as int?;
          recCarbs = parsedJson['recommended_carbs'] as int?;
          recFat = parsedJson['recommended_fat'] as int?;
          recCalories = parsedJson['recommended_calories'] as int?;

          // The general analysis part is everything before the JSON object
          generatedNotes = fullResponse.substring(0, jsonStartIndex).trim();
          if (generatedNotes.isEmpty) {
            generatedNotes =
                'AI analysis generated. See macro recommendations below.';
          }
        } else {
          // If no JSON is found, treat the entire response as notes
          generatedNotes = fullResponse;
          print('Warning: No structured JSON found in Gemini response.');
        }
      } catch (jsonError) {
        generatedNotes =
            fullResponse; // Fallback to full response if JSON parsing fails
        print('Error parsing JSON from Gemini response: $jsonError');
      }

      // Update Firestore with both analysis notes and macro recommendations
      await _userRepository.updateAiAnalysisNotes(
        firebaseUser.uid,
        generatedNotes,
      );
      await _userRepository.updateUserMacroRecommendations(
        firebaseUser.uid,
        protein: recProtein,
        carbs: recCarbs,
        fat: recFat,
        calories: recCalories,
      );

      // After updating Firestore, refresh the user profile to get the latest data
      await _loadUserProfile();
    } catch (e, st) {
      state = AsyncValue.error(
        'Error generating or saving AI analysis: $e',
        st,
      );
      print('Error in generateAndSaveAiAnalysis: $e \n $st');
    }
  }

  // Allows manual refresh of the user profile
  Future<void> refreshUserProfile() async {
    await _loadUserProfile();
  }
}
