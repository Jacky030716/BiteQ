import 'package:biteq/features/food_analysis/domain/entities/meals.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class MealRepository {
  final CollectionReference mealsCollection = FirebaseFirestore.instance
      .collection('meals');

  // Add a new meal
  Future<void> addMeal(Meal meal) async {
    try {
      await mealsCollection.doc(meal.name).set(meal.toJson());
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
              return Meal.fromJson(doc.data() as Map<String, dynamic>);
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
    try {
      await mealsCollection.doc(meal.name).update(meal.toJson());
    } on FirebaseException catch (e) {
      if (e.code == 'not-found') {
        // If meal doesn't exist, create it
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
        return Meal.fromJson(doc.data() as Map<String, dynamic>);
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
              return Meal.fromJson(doc.data() as Map<String, dynamic>);
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

  // Handle Firebase exceptions with user-friendly messages
  Exception _handleFirebaseException(FirebaseException e) {
    switch (e.code) {
      case 'permission-denied':
        return Exception(
          'Permission denied. Please check your authentication.',
        );
      case 'unavailable':
        return Exception(
          'Service is currently unavailable. Please try again later.',
        );
      case 'not-found':
        return Exception('Meal not found.');
      case 'already-exists':
        return Exception('Meal already exists.');
      case 'network-request-failed':
        return Exception(
          'Network error. Please check your internet connection.',
        );
      default:
        return Exception('An error occurred: ${e.message}');
    }
  }
}
