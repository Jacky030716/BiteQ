import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:biteq/features/profile/entities/profile_user.dart';

class UserRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<ProfileUser> fetchUserProfile() async {
    final user = _auth.currentUser;
    if (user == null) {
      throw Exception('User not logged in.');
    }
    try {
      final doc = await _firestore.collection('users').doc(user.uid).get();
      if (doc.exists && doc.data() != null) {
        // Use fromFirestore directly with the snapshot
        return ProfileUser.fromFirestore(doc, null);
      } else {
        throw Exception('User profile not found for UID: ${user.uid}');
      }
    } catch (e) {
      print('Error fetching user profile: $e');
      rethrow;
    }
  }

  /// Updates the AI analysis notes for a specific user.
  Future<void> updateAiAnalysisNotes(String userId, String notes) async {
    try {
      await _firestore.collection('users').doc(userId).update({
        'aiAnalysisNotes': notes,
      });
    } catch (e) {
      print('Error updating AI analysis notes for $userId: $e');
      rethrow;
    }
  }

  /// New method: Updates the recommended macronutrient values for a specific user.
  Future<void> updateUserMacroRecommendations(
    String userId, {
    int? protein,
    int? carbs,
    int? fat,
    int? calories,
  }) async {
    try {
      final Map<String, dynamic> updateData = {};
      if (protein != null) updateData['recommendedProtein'] = protein;
      if (carbs != null) updateData['recommendedCarbs'] = carbs;
      if (fat != null) updateData['recommendedFat'] = fat;
      if (calories != null) updateData['recommendedCalories'] = calories;

      if (updateData.isNotEmpty) {
        await _firestore.collection('users').doc(userId).update(updateData);
      }
    } catch (e) {
      print('Error updating user macro recommendations for $userId: $e');
      rethrow;
    }
  }

  /// Creates a new user profile document in Firestore.
  /// This is typically called after a new user registers.
  Future<void> createUserProfile({
    required String uid,
    required String email,
    required String name,
    required SurveyResponses surveyResponses,
  }) async {
    try {
      final ProfileUser newUser = ProfileUser(
        email: email,
        name: name,
        surveyResponses: surveyResponses,
        profileImageUrl: null, // Default to null initially
        aiAnalysisNotes: null, // Default to null initially
        recommendedProtein: null, // Default to null initially
        recommendedCarbs: null,
        recommendedFat: null,
        recommendedCalories: null,
      );
      await _firestore.collection('users').doc(uid).set(newUser.toFirestore());
    } catch (e) {
      print('Error creating user profile for $uid: $e');
      rethrow;
    }
  }

  /// Updates the user's profile image URL.
  Future<void> updateProfileImageUrl(String userId, String? imageUrl) async {
    try {
      await _firestore.collection('users').doc(userId).update({
        'profileImageUrl': imageUrl,
      });
    } catch (e) {
      print('Error updating profile image URL for $userId: $e');
      rethrow;
    }
  }

  /// Updates user survey responses.
  Future<void> updateSurveyResponses(
    String userId,
    SurveyResponses newResponses,
  ) async {
    try {
      await _firestore.collection('users').doc(userId).update({
        'survey_responses': newResponses.toJson(),
      });
    } catch (e) {
      print('Error updating survey responses for $userId: $e');
      rethrow;
    }
  }
}
