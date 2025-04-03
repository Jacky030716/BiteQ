import 'package:biteq/core/exceptions/firebase_auth_exceptions.dart';
import 'package:biteq/features/survey_form/data/models/user_survey.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class SurveyRepositories {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<void> submitSurvey(UserSurveyModel survey) async {
    try {
      // Get the current user
      final user = _auth.currentUser;

      if (user == null) {
        throw Exception('User not authenticated');
      }

      final userDocRef = _firestore.collection('users').doc(user.uid);
      final existingUser = await userDocRef.get();

      if (existingUser.exists) {
        final existingData = existingUser.data();
        final List<dynamic> surveyResponses =
            existingData?['survey_responses'] ?? [];

        surveyResponses.add(survey.toJson());

        await userDocRef.update({'survey_responses': surveyResponses});
      } else {
        await userDocRef.set({
          'survey_responses': [survey.toJson()],
        });
      }
    } on FirebaseAuthException catch (e) {
      throw TFirebaseAuthException.getException(e.code);
    } catch (e) {
      throw Exception('Failed to submit survey');
    }
  }

  Future<bool> getSurveyStatus(String email) async {
    try {
      final existingUser =
          await _firestore
              .collection('users')
              .where('email', isEqualTo: email)
              .limit(1)
              .get();

      if (existingUser.docs.isNotEmpty) {
        final data = existingUser.docs.first.data();
        final List<dynamic> surveyResponses = data['survey_responses'] ?? [];

        return surveyResponses.isNotEmpty;
      } else {
        return false; // User document does not exist
      }
    } on FirebaseAuthException catch (e) {
      throw TFirebaseAuthException.getException(e.code);
    } catch (e) {
      throw Exception('Failed to get survey status');
    }
  }
}
