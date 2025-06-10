import 'package:biteq/features/profile/entities/profile_user.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class UserRepository {
  final CollectionReference usersCollection = FirebaseFirestore.instance
      .collection("users");

  Future<ProfileUser> fetchUserProfile() async {
    try {
      // Get the current user from Firebase Authentication
      final currentUser = FirebaseAuth.instance.currentUser;

      if (currentUser == null) {
        throw FirebaseAuthException(
          code: 'user-not-logged-in',
          message: 'No user is currently logged in.',
        );
      }

      // Query Firestore for the user's profile using their UID
      final userSnapshot = await usersCollection.doc(currentUser.uid).get();

      if (!userSnapshot.exists || userSnapshot.data() == null) {
        throw FirebaseException(
          plugin: 'Firestore',
          message: 'User profile not found for UID: ${currentUser.uid}.',
          code: 'not-found',
        );
      }

      // Parse the user profile data.
      // Cast the data to Map<String, dynamic> safely.
      final userData = userSnapshot.data() as Map<String, dynamic>;
      return ProfileUser.fromJson(userData);
    } on FirebaseAuthException catch (e) {
      // Catch specific FirebaseAuth errors
      throw Exception('Authentication error: ${e.message}');
    } on FirebaseException catch (e) {
      // Catch specific Firestore errors
      throw Exception('Firestore error: ${e.message}');
    } catch (e) {
      // Catch any other unexpected errors
      throw Exception('Failed to fetch user profile: $e');
    }
  }

  // Optional: Method to update user profile
  Future<void> updateUserProfile(ProfileUser user) async {
    try {
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) {
        throw FirebaseAuthException(
          code: 'user-not-logged-in',
          message: 'No user is currently logged in.',
        );
      }
      await usersCollection
          .doc(currentUser.uid)
          .set(user.toJson(), SetOptions(merge: true));
    } on FirebaseAuthException catch (e) {
      throw Exception('Authentication error updating profile: ${e.message}');
    } on FirebaseException catch (e) {
      throw Exception('Firestore error updating profile: ${e.message}');
    } catch (e) {
      throw Exception('Failed to update user profile: $e');
    }
  }
}
