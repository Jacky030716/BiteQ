import 'dart:io'; // Import for File
import 'package:biteq/features/food_analysis/domain/entities/meals.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart'; // New: For user authentication
import 'package:firebase_storage/firebase_storage.dart'; // Import Firebase Storage
import 'package:biteq/features/food_analysis/domain/entities/food_item.dart'; // Ensure FoodItem is imported

class MealRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  // Helper to get the current authenticated user's ID
  String? get _currentUserId => _auth.currentUser?.uid;

  // Helper to format DateTime objects into a consistent string for Firestore document IDs (e.g., "YYYY-MM-DD")
  String _formatDateForFirestore(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  // Fetches the suggested macronutrient values for the current user.
  Future<Map<String, int>> getUserMacroRecommendations() async {
    final userId = _currentUserId;
    if (userId == null) {
      throw Exception(
        'User not authenticated. Cannot fetch macro recommendations.',
      );
    }

    try {
      final docSnapshot =
          await _firestore.collection('users').doc(userId).get();
      if (docSnapshot.exists) {
        final data = docSnapshot.data();
        return {
          'recommendedProtein': data?['recommendedProtein'] as int? ?? 0,
          'recommendedCarbs': data?['recommendedCarbs'] as int? ?? 0,
          'recommendedFat': data?['recommendedFat'] as int? ?? 0,
          'recommendedCalories': data?['recommendedCalories'] as int? ?? 0,
        };
      } else {
        // If user profile doesn't exist, return default zeros
        print(
          'User profile not found for UID: $userId. Returning default macro recommendations.',
        );
        return {
          'recommendedProtein': 0,
          'recommendedCarbs': 0,
          'recommendedFat': 0,
          'recommendedCalories': 0,
        };
      }
    } on FirebaseException catch (e) {
      print('Firebase Error fetching user macro recommendations: ${e.message}');
      rethrow; // Re-throw Firebase exceptions
    } catch (e) {
      print('General Error fetching user macro recommendations: $e');
      rethrow; // Re-throw any other exceptions
    }
  }

  /// Fetches all meals for a specific date for the current user.
  /// The data is structured as: `users/{userId}/meals_by_date/{YYYY-MM-DD}/mealTypes/{mealName}`
  /// Throws an [Exception] if the user is not authenticated.
  Future<List<Meal>> getMealsForDate(DateTime date) async {
    // Ensure user is authenticated before attempting to fetch data
    if (_currentUserId == null) {
      throw Exception('User not authenticated. Cannot fetch meals.');
    }

    final dateId = _formatDateForFirestore(
      date,
    ); // Get the date string for the document ID
    try {
      // Reference to the mealTypes subcollection for the specific user and date
      final mealsCollectionRef = _firestore
          .collection('users')
          .doc(_currentUserId) // User-specific document
          .collection('meals_by_date') // Collection for daily meals
          .doc(dateId) // Document for the specific date
          .collection('mealTypes');

      final querySnapshot = await mealsCollectionRef.get();

      return querySnapshot.docs.map((doc) {
        final data = doc.data();
        final List<FoodItem> foods =
            (data['foods'] as List<dynamic>?)
                ?.map(
                  (foodJson) =>
                      FoodItem.fromJson(foodJson as Map<String, dynamic>),
                )
                .toList() ??
            [];
        return Meal(
          id: doc.id, // The document ID here is the meal name (e.g., "Breakfast")
          name: data['name'] as String,
          mealIcon: data['mealIcon'] as String? ?? '',
          foods: foods,
          time: data['time'] as String? ?? '', // Ensure time field is parsed
          totalCals: data['totalCals'] as String? ?? '0 kcal',
          date: date, // Assign the date parameter to the Meal object
        );
      }).toList();
    } on FirebaseException catch (e) {
      // Handle known Firebase errors
      throw _handleFirebaseException(e);
    } catch (e) {
      // Handle any other unexpected errors
      print('Error getting meals for date $dateId: $e');
      throw Exception('Failed to get meals for date $dateId: $e');
    }
  }

  /// Adds a new meal type for a specific date. If the meal type already exists for the date,
  /// it will be merged (updated) with the new data.
  /// The meal's `name` property is used as the document ID within the `mealTypes` subcollection.
  /// Throws an [Exception] if the user is not authenticated.
  Future<void> addMeal(Meal meal) async {
    // Ensure user is authenticated
    if (_currentUserId == null) {
      throw Exception('User not authenticated. Cannot add meal.');
    }

    final dateId = _formatDateForFirestore(
      meal.date,
    ); // Get date string for path
    try {
      // Reference to the specific meal type document for the user and date
      final mealDocRef = _firestore
          .collection('users')
          .doc(_currentUserId)
          .collection('meals_by_date')
          .doc(dateId)
          .collection('mealTypes')
          .doc(meal.name); // Document ID is the meal name (e.g., "Breakfast")

      // Use `set` with `SetOptions(merge: true)` to either create the document
      // or update it if it already exists without overwriting other fields.
      await mealDocRef.set(meal.toJson(), SetOptions(merge: true));
    } on FirebaseException catch (e) {
      throw _handleFirebaseException(e);
    } catch (e) {
      print('Error adding meal type ${meal.name} for date $dateId: $e');
      throw Exception('Failed to add meal: $e');
    }
  }

  /// Updates an existing meal document, including its food items, total calories, and time.
  /// Throws an [Exception] if the user is not authenticated or the meal cannot be found.
  Future<void> updateMeal(Meal meal) async {
    // Ensure user is authenticated
    if (_currentUserId == null) {
      throw Exception('User not authenticated. Cannot update meal.');
    }

    // Ensure meal name is not empty as it's used for the document ID
    if (meal.name.isEmpty) {
      throw Exception('Meal name cannot be empty for updating.');
    }

    final dateId = _formatDateForFirestore(
      meal.date,
    ); // Get date string for path
    try {
      // Reference to the specific meal type document for the user and date
      final mealDocRef = _firestore
          .collection('users')
          .doc(_currentUserId)
          .collection('meals_by_date')
          .doc(dateId)
          .collection('mealTypes')
          .doc(meal.name);

      // Update specific fields of the meal document
      await mealDocRef.update({
        'foods':
            meal.foods
                .map((f) => f.toJson())
                .toList(), // Update the list of foods
        'totalCals': meal.totalCals, // Update total calories
        'time': meal.time, // Update time
      });
    } on FirebaseException catch (e) {
      // If the document doesn't exist, it implies a logic error or a race condition.
      // Firebase `update` method requires the document to exist.
      if (e.code == 'not-found') {
        // Option: if you want to create it if not found, use addMeal(meal) here instead
        throw Exception(
          'Meal document not found for update: ${meal.name} on $dateId',
        );
      }
      throw _handleFirebaseException(e);
    } catch (e) {
      print('Error updating meal ${meal.name} for date $dateId: $e');
      throw Exception('Failed to update meal: $e');
    }
  }

  /// Deletes a specific meal type document for a given date for the current user.
  /// Throws an [Exception] if the user is not authenticated.
  Future<void> deleteMeal(String mealName, DateTime date) async {
    // Ensure user is authenticated
    if (_currentUserId == null) {
      throw Exception('User not authenticated. Cannot delete meal.');
    }

    final dateId = _formatDateForFirestore(date); // Get date string for path
    try {
      // Reference to the specific meal type document to be deleted
      final mealDocRef = _firestore
          .collection('users')
          .doc(_currentUserId)
          .collection('meals_by_date')
          .doc(dateId)
          .collection('mealTypes')
          .doc(mealName);

      await mealDocRef.delete();
    } on FirebaseException catch (e) {
      throw _handleFirebaseException(e);
    } catch (e) {
      print('Error deleting meal ${mealName} for date $dateId: $e');
      throw Exception('Failed to delete meal: $e');
    }
  }

  /// Uploads a food image to Firebase Storage for the current user, organized by date and meal name.
  /// Returns the download URL of the uploaded image.
  /// Throws an [Exception] if the user is not authenticated or if upload fails.
  Future<String> uploadFoodImage(
    File imageFile,
    String mealName,
    String foodName,
  ) async {
    // Ensure user is authenticated
    if (_currentUserId == null) {
      throw Exception('User not authenticated for image upload.');
    }

    // Ensure mealName is valid for the storage path
    if (mealName.isEmpty) {
      throw Exception("Meal name cannot be empty for image upload path.");
    }

    try {
      // Create a unique file name using current timestamp and cleaned food name
      final String fileName =
          '${foodName.replaceAll(' ', '_')}_${DateTime.now().millisecondsSinceEpoch}.jpg';

      // Define the storage path: user_food_images/{userId}/{YYYY-MM-DD}/{mealName}/{fileName}
      final Reference storageRef = _storage
          .ref()
          .child(
            'user_food_images',
          ) // Top-level folder for all user food images
          .child(_currentUserId!) // User-specific folder
          .child(
            _formatDateForFirestore(DateTime.now()),
          ) // Subfolder for the current date of upload
          .child(mealName) // Subfolder for the meal type
          .child(fileName); // The actual image file name

      final UploadTask uploadTask = storageRef.putFile(imageFile);
      final TaskSnapshot snapshot = await uploadTask;
      final String downloadUrl = await snapshot.ref.getDownloadURL();
      return downloadUrl;
    } on FirebaseException catch (e) {
      throw Exception('Failed to upload image: ${e.message}');
    } catch (e) {
      rethrow;
    }
  }

  // Handles common Firebase exceptions and returns a more user-friendly [Exception].
  Exception _handleFirebaseException(FirebaseException e) {
    switch (e.code) {
      case 'permission-denied':
        return Exception(
          'Permission denied. Please check your authentication and Firestore security rules.',
        );
      case 'unavailable':
        return Exception(
          'Service is currently unavailable. Please try again later.',
        );
      case 'not-found':
        return Exception('Document not found in Firestore.');
      case 'already-exists':
        return Exception('Document already exists.');
      case 'network-request-failed':
        return Exception(
          'Network error. Please check your internet connection.',
        );
      case 'invalid-argument':
        return Exception('Invalid data provided: ${e.message}');
      case 'unauthenticated':
        return Exception('You are not authenticated. Please log in.');
      default:
        return Exception('An unexpected Firebase error occurred: ${e.message}');
    }
  }
}
