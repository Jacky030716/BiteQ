import 'dart:io'; // Import for File
import 'package:biteq/features/food_analysis/domain/entities/meals.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart'; // Import Firebase Storage

class MealRepository {
  final CollectionReference mealsCollection = FirebaseFirestore.instance
      .collection('meals');
  final FirebaseStorage _storage =
      FirebaseStorage.instance; // Initialize Firebase Storage

  // Add a new meal
  Future<void> addMeal(Meal meal) async {
    try {
      // Using meal.name as doc ID as per your existing structure
      await mealsCollection.doc(meal.name).set(meal.toJson());
      // Explicitly set meal.id to meal.name for consistency within the app if using name as ID
      meal.id = meal.name;
    } on FirebaseException catch (e) {
      throw _handleFirebaseException(e);
    } catch (e) {
      throw Exception('Failed to add meal: $e');
    }
  }

  // Get all meals
  Future<List<Meal>> getMeals() async {
    try {
      final snapshot = await mealsCollection.get();
      return snapshot.docs
          .map((doc) {
            try {
              // Ensure 'id' is set from doc.id, which corresponds to meal.name in your setup
              final data = doc.data() as Map<String, dynamic>;
              data['id'] = doc.id; // doc.id will be the meal.name here
              return Meal.fromJson(data);
            } catch (e) {
              // Log the error but continue with other meals
              print('Error parsing meal ${doc.id}: $e');
              return null;
            }
          })
          .where((meal) => meal != null)
          .cast<Meal>()
          .toList();
    } on FirebaseException catch (e) {
      throw _handleFirebaseException(e);
    } catch (e) {
      throw Exception('Failed to fetch meals: $e');
    }
  }

  // Update an existing meal
  Future<void> updateMeal(Meal meal) async {
    // Ensure meal.name is not null for document reference
    if (meal.name.isEmpty) {
      throw Exception('Meal name cannot be empty for updating.');
    }
    try {
      // Using meal.name as doc ID for update
      await mealsCollection.doc(meal.name).update(meal.toJson());
    } on FirebaseException catch (e) {
      if (e.code == 'not-found') {
        // If meal doesn't exist, create it (as per your original logic)
        await addMeal(meal);
      } else {
        throw _handleFirebaseException(e);
      }
    } catch (e) {
      throw Exception('Failed to update meal: $e');
    }
  }

  // Delete a meal
  Future<void> deleteMeal(String mealName) async {
    try {
      await mealsCollection.doc(mealName).delete();
    } on FirebaseException catch (e) {
      throw _handleFirebaseException(e);
    } catch (e) {
      throw Exception('Failed to delete meal: $e');
    }
  }

  // Get a specific meal by name
  Future<Meal?> getMealByName(String mealName) async {
    try {
      final doc = await mealsCollection.doc(mealName).get();
      if (doc.exists) {
        final data = doc.data() as Map<String, dynamic>;
        data['id'] = doc.id; // doc.id will be the meal.name here
        return Meal.fromJson(data);
      }
      return null;
    } on FirebaseException catch (e) {
      throw _handleFirebaseException(e);
    } catch (e) {
      throw Exception('Failed to fetch meal: $e');
    }
  }

  // Check if a meal exists
  Future<bool> mealExists(String mealName) async {
    try {
      final doc = await mealsCollection.doc(mealName).get();
      return doc.exists;
    } on FirebaseException catch (e) {
      throw _handleFirebaseException(e);
    } catch (e) {
      throw Exception('Failed to check meal existence: $e');
    }
  }

  // Get meals by time range (if you want to filter by day/week)
  Future<List<Meal>> getMealsByTimeRange(
    DateTime startTime,
    DateTime endTime,
  ) async {
    try {
      // This would require storing timestamps in your meals
      // For now, we'll just return all meals
      return await getMeals();
    } on FirebaseException catch (e) {
      throw _handleFirebaseException(e);
    } catch (e) {
      throw Exception('Failed to fetch meals by time range: $e');
    }
  }

  // Delete all meals (useful for testing or reset functionality)
  Future<void> deleteAllMeals() async {
    try {
      final snapshot = await mealsCollection.get();
      final batch = FirebaseFirestore.instance.batch();

      for (var doc in snapshot.docs) {
        batch.delete(doc.reference);
      }

      await batch.commit();
    } on FirebaseException catch (e) {
      throw _handleFirebaseException(e);
    } catch (e) {
      throw Exception('Failed to delete all meals: $e');
    }
  }

  // Get meals count
  Future<int> getMealsCount() async {
    try {
      final snapshot = await mealsCollection.get();
      return snapshot.docs.length;
    } on FirebaseException catch (e) {
      throw _handleFirebaseException(e);
    } catch (e) {
      throw Exception('Failed to get meals count: $e');
    }
  }

  // Listen to meals changes (real-time updates)
  Stream<List<Meal>> watchMeals() {
    return mealsCollection.snapshots().map((snapshot) {
      return snapshot.docs
          .map((doc) {
            try {
              final data = doc.data() as Map<String, dynamic>;
              data['id'] = doc.id;
              return Meal.fromJson(data);
            } catch (e) {
              print('Error parsing meal ${doc.id}: $e');
              return null;
            }
          })
          .where((meal) => meal != null)
          .cast<Meal>()
          .toList();
    });
  }

  // New method: Uploads an image to Firebase Storage and returns its download URL
  // Uses mealName directly in the path as it's the Firestore document ID
  Future<String> uploadFoodImage(
    File imageFile,
    String mealName,
    String foodName,
  ) async {
    try {
      // Ensure mealName is valid for the path
      if (mealName.isEmpty) {
        throw Exception("Meal name cannot be empty for image upload path.");
      }

      // Create a unique file name using food name and timestamp
      final String fileName =
          '${foodName.replaceAll(' ', '_')}_${DateTime.now().millisecondsSinceEpoch}.jpg';
      // Path: food_images/{mealName (which is the doc ID)}/{generated_filename}.jpg
      final Reference storageRef = _storage
          .ref()
          .child('food_images')
          .child(mealName)
          .child(fileName);

      final UploadTask uploadTask = storageRef.putFile(imageFile);
      final TaskSnapshot snapshot = await uploadTask;
      final String downloadUrl = await snapshot.ref.getDownloadURL();
      print('Image uploaded to Firebase Storage: $downloadUrl');
      return downloadUrl;
    } on FirebaseException catch (e) {
      print('Firebase Storage error uploading image: ${e.message}');
      throw Exception('Failed to upload image: ${e.message}');
    } catch (e) {
      print('Error uploading image: $e');
      rethrow;
    }
  }

  // Handle Firebase exceptions with user-friendly messages
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
        return Exception(
          'Document already exists (likely due to meal name duplication).',
        );
      case 'network-request-failed':
        return Exception(
          'Network error. Please check your internet connection.',
        );
      case 'invalid-argument':
        return Exception('Invalid data provided: ${e.message}');
      default:
        return Exception('An unexpected Firebase error occurred: ${e.message}');
    }
  }
}
