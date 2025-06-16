import 'dart:io'; // Import File
import 'package:biteq/features/food_analysis/data/repositories/meal_repositiory.dart';
import 'package:biteq/features/food_analysis/domain/entities/food_item.dart';
import 'package:biteq/features/food_analysis/domain/entities/meals.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';
import 'package:biteq/features/food_analysis/presentation/widgets/analyze_date_selection.dart';

final mealViewModelProvider =
    StateNotifierProvider<MealViewModel, AsyncValue<List<Meal>>>((ref) {
      final selectedDate = ref.watch(selectedDateProvider);
      return MealViewModel(ref, selectedDate);
    });

class MealViewModel extends StateNotifier<AsyncValue<List<Meal>>> {
  final MealRepository _mealRepository = MealRepository();
  final Ref _ref;
  DateTime _currentSelectedDate;

  MealViewModel(this._ref, this._currentSelectedDate)
    : super(const AsyncValue.loading()) {
    _ref.listen<DateTime>(selectedDateProvider, (previous, next) {
      if (!isSameDay(previous, next)) {
        _currentSelectedDate = next;
        fetchMeals();
      }
    });
    _initializeData();
  }

  bool isSameDay(DateTime? date1, DateTime? date2) {
    if (date1 == null || date2 == null) return false;
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
  }

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

  Future<void> fetchMeals() async {
    try {
      if (mounted) {
        // Ensure notifier is mounted before updating state
        state = const AsyncValue.loading();
      }
      final allMeals = await _mealRepository.getMeals();
      final filteredMeals =
          allMeals
              .where((meal) => isSameDay(meal.date, _currentSelectedDate))
              .toList();
      if (mounted) {
        // Ensure notifier is mounted before updating state
        state = AsyncValue.data(filteredMeals);
      }
    } catch (error) {
      if (mounted) {
        state = AsyncValue.error(error, StackTrace.current);
      }
      debugPrint('Error fetching meals for date $_currentSelectedDate: $error');
    }
  }

  Future<void> addNewMeal(String mealType, String mealIcon, String time) async {
    try {
      final currentState = state;
      if (currentState is! AsyncData) return;

      final newMeal = Meal(
        name: mealType,
        mealIcon: mealIcon,
        foods: [],
        time: time,
        totalCals: '0 Cals',
        date: _currentSelectedDate,
      );

      await _mealRepository.addMeal(newMeal);
      await fetchMeals();
    } catch (error) {
      if (mounted) {
        state = AsyncError(error, StackTrace.current);
      }
      rethrow;
    }
  }

  Future<void> updateMeal(Meal meal) async {
    try {
      await _mealRepository.updateMeal(meal);
      await fetchMeals();
    } catch (error) {
      if (mounted) {
        state = AsyncValue.error(error, StackTrace.current);
      }
    }
  }

  Future<void> deleteMeal(String mealName) async {
    try {
      final currentState = state;
      if (currentState is! AsyncData) return;

      final currentMeals = currentState.value ?? [];
      final mealToDelete = currentMeals.firstWhere(
        (meal) =>
            meal.name == mealName && isSameDay(meal.date, _currentSelectedDate),
        orElse:
            () =>
                throw Exception(
                  'Meal not found for deletion on selected date.',
                ),
      );

      await _mealRepository.deleteMeal(
        mealToDelete.name,
      ); // Using meal.name as ID
      await fetchMeals();
    } catch (error) {
      if (mounted) {
        state = AsyncError(error, StackTrace.current);
      }
      rethrow;
    }
  }

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

  // Modified: addFoodItem now accepts a File? for image upload and processes it
  Future<void> addFoodItem(
    String mealName,
    FoodItem food,
    File? imageFile,
  ) async {
    final currentState = state;
    if (currentState is AsyncData<List<Meal>>) {
      try {
        final meals = [...currentState.value];
        final mealIndex = meals.indexWhere(
          (meal) =>
              meal.name == mealName &&
              isSameDay(meal.date, _currentSelectedDate),
        );
        if (mealIndex == -1) {
          throw Exception('Meal not found for selected date: $mealName');
        }

        // --- Image Upload Logic ---
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

        meals[mealIndex].foods.add(foodWithImageUrl);
        meals[mealIndex].updateTotalCalories();

        await _mealRepository.updateMeal(meals[mealIndex]);
        await fetchMeals();
      } catch (error) {
        if (mounted) {
          state = AsyncValue.error(error, StackTrace.current);
        }
        debugPrint('Error adding food item: $error');
        await fetchMeals();
      }
    }
  }

  Future<void> removeFoodItem(String mealName, int foodIndex) async {
    final currentState = state;
    if (currentState is AsyncData<List<Meal>>) {
      try {
        final meals = [...currentState.value];
        final mealIndex = meals.indexWhere(
          (meal) =>
              meal.name == mealName &&
              isSameDay(meal.date, _currentSelectedDate),
        );
        if (mealIndex == -1) {
          throw Exception('Meal not found for selected date: $mealName');
        }

        if (foodIndex < 0 || foodIndex >= meals[mealIndex].foods.length) {
          throw Exception('Invalid food item index');
        }

        meals[mealIndex].foods.removeAt(foodIndex);
        meals[mealIndex].updateTotalCalories();

        await _mealRepository.updateMeal(meals[mealIndex]);
        await fetchMeals();
      } catch (error) {
        if (mounted) {
          state = AsyncValue.error(error, StackTrace.current);
        }
        debugPrint('Error removing food item: $error');
        await fetchMeals();
      }
    }
  }

  Future<void> updateFoodItem(
    String mealName,
    int foodIndex,
    FoodItem updatedFood,
  ) async {
    final currentState = state;
    if (currentState is AsyncData<List<Meal>>) {
      try {
        final meals = [...currentState.value];
        final mealIndex = meals.indexWhere(
          (meal) =>
              meal.name == mealName &&
              isSameDay(meal.date, _currentSelectedDate),
        );
        if (mealIndex == -1) {
          throw Exception('Meal not found for selected date: $mealName');
        }

        if (foodIndex < 0 || foodIndex >= meals[mealIndex].foods.length) {
          throw Exception('Invalid food item index');
        }

        meals[mealIndex].foods[foodIndex] = updatedFood;
        meals[mealIndex].updateTotalCalories();

        await _mealRepository.updateMeal(meals[mealIndex]);
        await fetchMeals();
      } catch (error) {
        if (mounted) {
          state = AsyncValue.error(error, StackTrace.current);
        }
        debugPrint('Error updating food item: $error');
        await fetchMeals();
      }
    }
  }

  Future<void> refresh() async {
    await fetchMeals();
  }

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
