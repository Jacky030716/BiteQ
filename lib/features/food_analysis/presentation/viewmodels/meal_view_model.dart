import 'package:biteq/features/food_analysis/data/repositories/meal_repositiory.dart';
import 'package:biteq/features/food_analysis/domain/entities/food_item.dart';
import 'package:biteq/features/food_analysis/domain/entities/meals.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';

final mealViewModelProvider =
    StateNotifierProvider<MealViewModel, AsyncValue<List<Meal>>>((ref) {
      return MealViewModel();
    });

class MealViewModel extends StateNotifier<AsyncValue<List<Meal>>> {
  final MealRepository _mealRepository = MealRepository();

  MealViewModel() : super(const AsyncValue.loading()) {
    _initializeData();
  }

  // Initialize with mock data and load from repository
  Future<void> _initializeData() async {
    try {
      // First, add mock data to repository if it doesn't exist
      await _addMockDataIfNeeded();
      // Then fetch meals from repository
      await fetchMeals();
    } catch (error) {
      state = AsyncValue.error(error, StackTrace.current);
    }
  }

  // Add mock data to repository if no meals exist
  Future<void> _addMockDataIfNeeded() async {
    try {
      final existingMeals = await _mealRepository.getMeals();
      if (existingMeals.isEmpty) {
        final mockMeals = _getMockMeals();
        for (var meal in mockMeals) {
          await _mealRepository.addMeal(meal);
        }
      }
    } catch (error) {
      // Log or handle the error, but don't blindly add mock data here if fetching failed.
      // The assumption is that if getMeals() failed, adding mock data might also fail,
      // or we might already be in a bad state.
      // If mock data is absolutely critical even on fetch failure, then you could
      // re-evaluate, but for now, we'll let fetchMeals() handle the primary error.
      debugPrint('Error checking for existing meals: $error');
    }
  }

  // Generate mock meals data
  List<Meal> _getMockMeals() {
    return [
      Meal(
        name: "Breakfast",
        mealIcon: "assets/icons/breakfast.png",
        time: "7:30 AM",
        totalCals: "398 Cals",
        foods: [
          FoodItem(
            name: "Oatmeal with Berries",
            calories: "210 calories",
            image: "",
            time: "7:35 AM",
          ),
          FoodItem(
            name: "Greek Yogurt",
            calories: "138 calories",
            image: "",
            time: "7:40 AM",
          ),
          FoodItem(
            name: "Fresh Orange Juice",
            calories: "50 calories",
            image: "",
            time: "7:45 AM",
          ),
        ],
      ),
      Meal(
        name: "Lunch",
        mealIcon: "assets/icons/lunch.png",
        time: "12:15 PM",
        totalCals: "485 Cals",
        foods: [
          FoodItem(
            name: "Grilled Chicken Breast",
            calories: "250 calories",
            image: "",
            time: "12:20 PM",
          ),
          FoodItem(
            name: "Brown Rice",
            calories: "185 calories",
            image: "",
            time: "12:25 PM",
          ),
          FoodItem(
            name: "Mixed Vegetables",
            calories: "50 calories",
            image: "",
            time: "12:30 PM",
          ),
        ],
      ),
      Meal(
        name: "Dinner",
        mealIcon: "assets/icons/dinner.png",
        time: "6:45 PM",
        totalCals: "520 Cals",
        foods: [
          FoodItem(
            name: "Grilled Salmon",
            calories: "280 calories",
            image: "",
            time: "6:50 PM",
          ),
          FoodItem(
            name: "Steamed Broccoli",
            calories: "90 calories",
            image: "",
            time: "6:55 PM",
          ),
          FoodItem(
            name: "Quinoa Salad",
            calories: "150 calories",
            image: "",
            time: "7:00 PM",
          ),
        ],
      ),
      Meal(
        name: "Snack",
        mealIcon: "assets/icons/snack.png",
        time: "3:30 PM",
        totalCals: "180 Cals",
        foods: [
          FoodItem(
            name: "Apple Slices",
            calories: "80 calories",
            image: "",
            time: "3:35 PM",
          ),
          FoodItem(
            name: "Almond Butter",
            calories: "100 calories",
            image: "",
            time: "3:35 PM",
          ),
        ],
      ),
    ];
  }

  Future<void> addMockMeals() async {
    final meals = <Meal>[
      Meal(
        name: 'Breakfast',
        time: '07:30 AM',
        mealIcon: '🍳',
        totalCals: '',
        foods: [
          FoodItem(
            name: 'Boiled Egg',
            calories: '78 Cals',
            image: '🥚',
            time: '07:31 AM',
          ),
          FoodItem(
            name: 'Toast',
            calories: '120 Cals',
            image: '🍞',
            time: '07:32 AM',
          ),
          FoodItem(
            name: 'Orange Juice',
            calories: '150 Cals',
            image: '🍊',
            time: '07:33 AM',
          ),
        ],
      ),
      Meal(
        name: 'Lunch',
        time: '12:45 PM',
        mealIcon: '🍱',
        totalCals: '',
        foods: [
          FoodItem(
            name: 'Rice',
            calories: '200 Cals',
            image: '🍚',
            time: '12:46 PM',
          ),
          FoodItem(
            name: 'Grilled Chicken',
            calories: '250 Cals',
            image: '🍗',
            time: '12:47 PM',
          ),
          FoodItem(
            name: 'Salad',
            calories: '80 Cals',
            image: '🥗',
            time: '12:48 PM',
          ),
        ],
      ),
      Meal(
        name: 'Dinner',
        time: '07:00 PM',
        mealIcon: '🍝',
        totalCals: '',
        foods: [
          FoodItem(
            name: 'Spaghetti',
            calories: '300 Cals',
            image: '🍝',
            time: '07:01 PM',
          ),
          FoodItem(
            name: 'Meatballs',
            calories: '200 Cals',
            image: '🥩',
            time: '07:02 PM',
          ),
          FoodItem(
            name: 'Watermelon',
            calories: '50 Cals',
            image: '🍉',
            time: '07:03 PM',
          ),
        ],
      ),
    ];

    for (var meal in meals) {
      meal.updateTotalCalories(); // auto-calculate total
      await _mealRepository.addMeal(meal);
    }
  }

  // Fetch meals from repository
  Future<void> fetchMeals() async {
    try {
      state = const AsyncValue.loading();
      final meals = await _mealRepository.getMeals();
      state = AsyncValue.data(meals);
    } catch (error) {
      state = AsyncValue.error(error, StackTrace.current);
    }
  }

  Future<void> addNewMeal(String mealType, String mealIcon, String time) async {
    try {
      // Get current state
      final currentState = state;
      if (currentState is! AsyncData) return;

      final currentMeals = currentState.value ?? [];

      final newMeal = Meal(
        name: mealType,
        mealIcon: mealIcon,
        foods: [],
        time: time,
        totalCals: '0 Cals',
      );

      // Add to database (adjust according to your repository/service)
      await _mealRepository.addMeal(newMeal);

      // Update state with new meal
      final updatedMeals = [...currentMeals, newMeal];
      state = AsyncData(updatedMeals);
    } catch (error) {
      // Handle error appropriately
      state = AsyncError(error, StackTrace.current);
      rethrow;
    }
  }

  // Update an existing meal
  Future<void> updateMeal(Meal meal) async {
    try {
      await _mealRepository.updateMeal(meal);
      await fetchMeals(); // Refresh the list
    } catch (error) {
      state = AsyncValue.error(error, StackTrace.current);
    }
  }

  // Delete a meal
  Future<void> deleteMeal(int mealIndex) async {
    try {
      final currentState = state;
      if (currentState is! AsyncData) return;

      final currentMeals = currentState.value ?? [];

      if (mealIndex < 0 || mealIndex >= currentMeals.length) {
        throw Exception('Invalid meal index');
      }

      final mealToDelete = currentMeals[mealIndex];

      // Delete from database
      await _mealRepository.deleteMeal(mealToDelete.name);

      // Update state by removing the meal
      final updatedMeals = List<Meal>.from(currentMeals);
      updatedMeals.removeAt(mealIndex);

      state = AsyncData(updatedMeals);
    } catch (error) {
      state = AsyncError(error, StackTrace.current);
      rethrow;
    }
  }

  // Get meal by name
  Future<Meal?> getMealByName(String mealName) async {
    try {
      return await _mealRepository.getMealByName(mealName);
    } catch (error) {
      return null;
    }
  }

  // Add a new food item to a meal
  Future<void> addFoodItem(int mealIndex, FoodItem food) async {
    final currentState = state;
    if (currentState is AsyncData<List<Meal>>) {
      try {
        final meals = [...currentState.value];
        meals[mealIndex].foods.add(food);
        meals[mealIndex].updateTotalCalories();

        // Update in repository
        await _mealRepository.updateMeal(meals[mealIndex]);

        // Update local state
        state = AsyncValue.data(meals);
      } catch (error) {
        state = AsyncValue.error(error, StackTrace.current);
        // Refresh from repository on error
        await fetchMeals();
      }
    }
  }

  // Remove a food item from a meal
  Future<void> removeFoodItem(int mealIndex, int foodIndex) async {
    final currentState = state;
    if (currentState is AsyncData<List<Meal>>) {
      try {
        final meals = [...currentState.value];
        meals[mealIndex].foods.removeAt(foodIndex);
        meals[mealIndex].updateTotalCalories();

        // Update in repository
        await _mealRepository.updateMeal(meals[mealIndex]);

        // Update local state
        state = AsyncValue.data(meals);
      } catch (error) {
        state = AsyncValue.error(error, StackTrace.current);
        // Refresh from repository on error
        await fetchMeals();
      }
    }
  }

  // Update an existing food item
  Future<void> updateFoodItem(
    int mealIndex,
    int foodIndex,
    FoodItem updatedFood,
  ) async {
    final currentState = state;
    if (currentState is AsyncData<List<Meal>>) {
      try {
        final meals = [...currentState.value];
        meals[mealIndex].foods[foodIndex] = updatedFood;
        meals[mealIndex].updateTotalCalories();

        // Update in repository
        await _mealRepository.updateMeal(meals[mealIndex]);

        // Update local state
        state = AsyncValue.data(meals);
      } catch (error) {
        state = AsyncValue.error(error, StackTrace.current);
        // Refresh from repository on error
        await fetchMeals();
      }
    }
  }

  // Refresh meals from repository
  Future<void> refresh() async {
    await fetchMeals();
  }

  // Get color for a meal type
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

  // Get total daily calories
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

  // Get meals count
  int getMealsCount() {
    final currentState = state;
    if (currentState is AsyncData<List<Meal>>) {
      return currentState.value.length;
    }
    return 0;
  }
}
