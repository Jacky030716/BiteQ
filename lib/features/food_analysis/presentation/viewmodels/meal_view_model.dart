import 'dart:io'; // Import File
import 'package:biteq/features/food_analysis/data/repositories/meal_repositiory.dart';
import 'package:biteq/features/food_analysis/domain/entities/food_item.dart';
import 'package:biteq/features/food_analysis/domain/entities/meals.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';
import 'package:biteq/features/food_analysis/presentation/widgets/analyze_date_selection.dart';

// Provider for the currently selected date (assuming this is correctly defined elsewhere)
// final selectedDateProvider = StateProvider<DateTime>((ref) => DateTime.now());

// Main MealViewModel provider
final mealViewModelProvider =
    StateNotifierProvider<MealViewModel, AsyncValue<List<Meal>>>((ref) {
      final selectedDate = ref.watch(selectedDateProvider);
      return MealViewModel(ref, selectedDate);
    });

// NEW: FutureProvider for recommended macronutrient values, directly fetching from MealRepository
final recommendedMacrosProvider = FutureProvider<Map<String, int>>((ref) async {
  final mealRepository = ref.read(
    mealRepositoryProvider,
  ); // Use a Provider for the repository
  return mealRepository.getUserMacroRecommendations();
});

// Define a provider for MealRepository so it can be read by other providers
final mealRepositoryProvider = Provider((ref) => MealRepository());

class MealViewModel extends StateNotifier<AsyncValue<List<Meal>>> {
  // Use a provider to get the MealRepository instance
  final MealRepository _mealRepository;
  final Ref _ref;
  DateTime _currentSelectedDate;

  MealViewModel(this._ref, this._currentSelectedDate)
    : _mealRepository = _ref.read(
        mealRepositoryProvider,
      ), // Initialize repository using ref.read
      super(const AsyncValue.loading()) {
    _ref.listen<DateTime>(selectedDateProvider, (previous, next) {
      if (!isSameDay(previous, next)) {
        _currentSelectedDate = next;
        fetchMeals(); // Fetch meals for the new date
      }
    });
    _initializeData();
  }

  /// Checks if two DateTimes represent the same day.
  bool isSameDay(DateTime? date1, DateTime? date2) {
    if (date1 == null || date2 == null) return false;
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
  }

  /// Initializes data by fetching meals.
  Future<void> _initializeData() async {
    try {
      await fetchMeals();
    } catch (error) {
      if (mounted) {
        state = AsyncValue.error(error, StackTrace.current);
      }
      debugPrint('Error initializing MealViewModel: $error');
    }
  }

  // Fetch user macro nutrient recommendations
  // This method is now primarily for internal MealViewModel logic if needed,
  // as the UI will likely consume recommendedMacrosProvider directly.
  Future<Map<String, int>> getNutrientsRecommendations() async {
    try {
      // This directly fetches from the repository
      final nutrients = await _mealRepository.getUserMacroRecommendations();
      return nutrients;
    } catch (e, st) {
      // Error handling here for internal use, UI handles its own error states
      debugPrint('Error in getNutrientsRecommendations: $e \n $st');
      throw Exception('Failed to fetch nutrient recommendations: $e');
    }
  }

  /// Fetches meals for the currently selected date using the repository.
  /// This now queries Firestore for only the relevant date.
  Future<void> fetchMeals() async {
    try {
      if (mounted) {
        state = const AsyncValue.loading();
      }
      // Use the repository to get meals specifically for the current selected date
      final mealsForDate = await _mealRepository.getMealsForDate(
        _currentSelectedDate,
      );

      if (mounted) {
        state = AsyncValue.data(mealsForDate); // No need to filter here
      }
    } catch (error) {
      if (mounted) {
        state = AsyncValue.error(error, StackTrace.current);
      }
      debugPrint('Error fetching meals for date $_currentSelectedDate: $error');
    }
  }

  /// Adds a new meal type (e.g., "Breakfast") for the current date.
  /// This is typically called when no meals exist for a date, or if a new meal type is explicitly created.
  Future<void> addNewMeal(String mealType, String mealIcon, String time) async {
    try {
      final newMeal = Meal(
        name: mealType,
        mealIcon: mealIcon,
        foods: [], // New meal type starts with an empty food list
        time: time,
        totalCals: '0 Cals',
        date: _currentSelectedDate,
      );

      await _mealRepository.addMeal(newMeal);
      await fetchMeals(); // Refresh UI after adding
    } catch (error) {
      if (mounted) {
        state = AsyncError(error, StackTrace.current);
      }
      rethrow;
    }
  }

  /// Updates an entire meal object.
  Future<void> updateMeal(Meal meal) async {
    try {
      await _mealRepository.updateMeal(meal);
      await fetchMeals(); // Refresh UI after update
    } catch (error) {
      if (mounted) {
        state = AsyncValue.error(error, StackTrace.current);
      }
      debugPrint('Error updating meal: $error');
    }
  }

  /// Deletes a meal type for the current date.
  Future<void> deleteMeal(String mealName) async {
    try {
      // MealRepository.deleteMeal now requires the date
      await _mealRepository.deleteMeal(mealName, _currentSelectedDate);
      await fetchMeals(); // Refresh UI after deletion
    } catch (error) {
      if (mounted) {
        state = AsyncError(error, StackTrace.current);
      }
      rethrow;
    }
  }

  /// Gets a specific meal by name for the current date.
  Future<Meal?> getMealByName(String mealName) async {
    final currentState = state;
    if (currentState is AsyncData<List<Meal>>) {
      return currentState.value.firstWhere(
        (meal) =>
            meal.name == mealName && isSameDay(meal.date, _currentSelectedDate),
        orElse: () => throw Exception('Meal not found for selected date'),
      );
    }
    return null;
  }

  /// Adds a new food item to an existing meal.
  /// If the meal type does not exist for the selected date, it creates it first.
  Future<void> addFoodItem(
    String mealName,
    FoodItem food,
    File? imageFile,
  ) async {
    try {
      // First, check if the meal type exists for the current date
      Meal? mealToUpdate;
      final currentStateData =
          state.asData?.value; // Safely access current data

      if (currentStateData != null) {
        try {
          mealToUpdate = currentStateData.firstWhere(
            (meal) =>
                meal.name == mealName &&
                isSameDay(meal.date, _currentSelectedDate),
          );
        } catch (e) {
          // Meal not found in current state, will be null
          mealToUpdate = null;
        }
      }

      // If meal type doesn't exist for this date, create it
      if (mealToUpdate == null) {
        // Provide default icon and time for a new meal type
        final String defaultMealIcon = _getMealIcon(mealName);
        final String defaultTime = _formatTime(
          TimeOfDay.now(),
        ); // Or a default based on mealName

        await addNewMeal(mealName, defaultMealIcon, defaultTime);
        // After adding a new meal, re-fetch all meals to ensure state is updated
        // and the newly created meal is available for modification.
        await fetchMeals();

        // Now, get the newly added meal from the refreshed state
        // Use a temporary variable for the current state to avoid potential state changes during async calls
        final refreshedStateData = state.asData?.value;
        if (refreshedStateData != null) {
          mealToUpdate = refreshedStateData.firstWhere(
            (meal) =>
                meal.name == mealName &&
                isSameDay(meal.date, _currentSelectedDate),
            orElse:
                () =>
                    throw Exception(
                      'Failed to retrieve newly added meal: $mealName',
                    ),
          );
        } else {
          throw Exception('Meal state is not available after adding new meal.');
        }
      }

      // Proceed with image upload and food item addition
      String? imageUrl =
          food.image; // Default to existing image (emoji or empty)
      if (imageFile != null) {
        imageUrl = await _mealRepository.uploadFoodImage(
          imageFile,
          mealName,
          food.name,
        );
      }

      final foodWithImageUrl = food.copyWith(image: imageUrl);

      // Create a copy of the foods list to modify it immutably
      final updatedFoods = List<FoodItem>.from(mealToUpdate.foods)
        ..add(foodWithImageUrl);

      // Calculate new total calories
      final newTotalCalories = updatedFoods.fold(0.0, (sum, item) {
        final calString = item.calories.split(' ')[0];
        return sum + (double.tryParse(calString) ?? 0);
      });
      final updatedTotalCals =
          '${newTotalCalories.toStringAsFixed(0)} calories';

      // Update the meal in the repository
      await _mealRepository.updateMeal(
        mealToUpdate.copyWith(foods: updatedFoods, totalCals: updatedTotalCals),
      );

      await fetchMeals(); // Refresh UI
    } catch (error, st) {
      if (mounted) {
        state = AsyncValue.error(error, st);
      }
      debugPrint('Error adding food item: $error \n $st');
      // No need to call fetchMeals here again, as it's already done above on success
    }
  }

  /// Removes a food item from an existing meal.
  Future<void> removeFoodItem(String mealName, int foodIndex) async {
    final currentState = state;
    if (currentState is! AsyncData<List<Meal>>) return;

    try {
      final mealToUpdate = currentState.value.firstWhere(
        (meal) =>
            meal.name == mealName && isSameDay(meal.date, _currentSelectedDate),
        orElse:
            () =>
                throw Exception('Meal not found for selected date: $mealName'),
      );

      if (foodIndex < 0 || foodIndex >= mealToUpdate.foods.length) {
        throw Exception('Invalid food item index');
      }

      // Create a copy of the foods list to modify it immutably
      final updatedFoods = List<FoodItem>.from(mealToUpdate.foods);
      updatedFoods.removeAt(foodIndex);

      // Calculate new total calories
      final newTotalCalories = updatedFoods.fold(0.0, (sum, item) {
        final calString = item.calories.split(' ')[0];
        return sum + (double.tryParse(calString) ?? 0);
      });
      final updatedTotalCals =
          '${newTotalCalories.toStringAsFixed(0)} calories';

      if (updatedFoods.isEmpty) {
        // If no more foods in this meal type, delete the mealType document
        await _mealRepository.deleteMeal(mealName, _currentSelectedDate);
      } else {
        // Update the meal in the repository
        await _mealRepository.updateMeal(
          mealToUpdate.copyWith(
            foods: updatedFoods,
            totalCals: updatedTotalCals,
          ),
        );
      }

      await fetchMeals(); // Refresh UI
    } catch (error, st) {
      if (mounted) {
        state = AsyncValue.error(error, st);
      }
      debugPrint('Error removing food item: $error \n $st');
      // No need to call fetchMeals here again, as it's already done above on success
    }
  }

  /// Updates a specific food item within an existing meal.
  Future<void> updateFoodItem(
    String mealName,
    int foodIndex,
    FoodItem updatedFood,
  ) async {
    final currentState = state;
    if (currentState is! AsyncData<List<Meal>>) return;

    try {
      final mealToUpdate = currentState.value.firstWhere(
        (meal) =>
            meal.name == mealName && isSameDay(meal.date, _currentSelectedDate),
        orElse:
            () =>
                throw Exception('Meal not found for selected date: $mealName'),
      );

      if (foodIndex < 0 || foodIndex >= mealToUpdate.foods.length) {
        throw Exception('Invalid food item index');
      }

      // Create a copy of the foods list to modify it immutably
      final updatedFoods = List<FoodItem>.from(mealToUpdate.foods);
      updatedFoods[foodIndex] = updatedFood; // Update the specific food item

      // Calculate new total calories
      final newTotalCalories = updatedFoods.fold(0.0, (sum, item) {
        final calString = item.calories.split(' ')[0];
        return sum + (double.tryParse(calString) ?? 0);
      });
      final updatedTotalCals =
          '${newTotalCalories.toStringAsFixed(0)} calories';

      // Update the meal in the repository
      await _mealRepository.updateMeal(
        mealToUpdate.copyWith(foods: updatedFoods, totalCals: updatedTotalCals),
      );

      await fetchMeals(); // Refresh UI
    } catch (error, st) {
      if (mounted) {
        state = AsyncValue.error(error, st);
      }
      debugPrint('Error updating food item: $error \n $st');
      // No need to call fetchMeals here again, as it's already done above on success
    }
  }

  // Refreshes the meal data for the current selected date.
  Future<void> refresh() async {
    await fetchMeals();
  }

  // Helper function to get default meal icon based on meal name
  String _getMealIcon(String mealName) {
    switch (mealName.toLowerCase()) {
      case 'breakfast':
        return 'assets/icons/breakfast.png'; // Assuming you have these icons
      case 'lunch':
        return 'assets/icons/lunch.png';
      case 'dinner':
        return 'assets/icons/dinner.png';
      case 'snack':
        return 'assets/icons/snack.png';
      default:
        return 'assets/icons/default_meal.png';
    }
  }

  // Helper function to format TimeOfDay to String
  String _formatTime(TimeOfDay time) {
    final hour = time.hourOfPeriod == 0 ? 12 : time.hourOfPeriod;
    final minute = time.minute.toString().padLeft(2, '0');
    final period = time.period == DayPeriod.am ? 'AM' : 'PM';
    return '$hour:$minute $period';
  }

  // Utility methods (colors, calorie calculations) remain mostly the same
  Color getMealColor(String mealName) {
    switch (mealName.toLowerCase()) {
      case "breakfast":
        return Colors.green.shade200;
      case "lunch":
        return Colors.orange.shade200;
      case "dinner":
        return Colors.deepPurple.shade200;
      case "snack":
        return Colors.blue.shade200;
      default:
        return Colors.grey.shade200;
    }
  }

  int getTotalDailyCalories() {
    final currentState = state;
    if (currentState is AsyncData<List<Meal>>) {
      return currentState.value.fold(0, (total, meal) {
        return total +
            meal.foods.fold(0, (mealTotal, food) {
              return mealTotal + food.caloriesValue;
            });
      });
    }
    return 0;
  }

  int getProteinGrams() {
    final currentState = state;
    if (currentState is AsyncData<List<Meal>>) {
      return currentState.value.fold(0, (total, meal) {
        return total +
            meal.foods.fold(0, (mealTotal, food) {
              return mealTotal + (food.protein ?? 0);
            });
      });
    }
    return 0;
  }

  int getCarbsGrams() {
    final currentState = state;
    if (currentState is AsyncData<List<Meal>>) {
      return currentState.value.fold(0, (total, meal) {
        return total +
            meal.foods.fold(0, (mealTotal, food) {
              return mealTotal + (food.carbs ?? 0);
            });
      });
    }
    return 0;
  }

  int getFatGrams() {
    final currentState = state;
    if (currentState is AsyncData<List<Meal>>) {
      return currentState.value.fold(0, (total, meal) {
        return total +
            meal.foods.fold(0, (mealTotal, food) {
              return mealTotal + (food.fat ?? 0);
            });
      });
    }
    return 0;
  }

  int getMealsCount() {
    final currentState = state;
    if (currentState is AsyncData<List<Meal>>) {
      return currentState.value.length;
    }
    return 0;
  }
}
