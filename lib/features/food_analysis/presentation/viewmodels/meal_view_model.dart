import 'package:biteq/features/food_analysis/domain/entities/food_item.dart';
import 'package:biteq/features/food_analysis/domain/entities/meals.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';

final mealViewModelProvider = StateNotifierProvider<MealViewModel, List<Meal>>((
  ref,
) {
  return MealViewModel();
});

class MealViewModel extends StateNotifier<List<Meal>> {
  List<Meal> _meals = [];

  List<Meal> get meals => _meals;

  MealViewModel() : super([]) {
    _loadInitialData();
  }

  void _loadInitialData() {
    // Sample data - in a real app, this would come from a repository
    state = [
      Meal(
        name: "Breakfast",
        mealIcon: "assets/icons/breakfast.png",
        time: "7:30 AM",
        totalCals: "398 Cals",
        foods: [
          FoodItem(
            name: "Oatmeal",
            calories: "210 calories",
            image: "assets/images/curry_rice.png",
            time: "7:35 AM",
          ),
          FoodItem(
            name: "Truroots Organic",
            calories: "138 calories",
            image: "assets/images/curry_rice.png",
            time: "7:40 AM",
          ),
          FoodItem(
            name: "Orange Juice",
            calories: "50 calories",
            image: "assets/images/curry_rice.png",
            time: "7:45 AM",
          ),
        ],
      ),
      Meal(
        name: "Lunch",
        mealIcon: "assets/icons/lunch.png",
        time: "12:15 PM",
        totalCals: "421 Cals",
        foods: [
          FoodItem(
            name: "BBQ Meat",
            calories: "210 calories",
            image: "assets/images/curry_rice.png",
            time: "12:20 PM",
          ),
          FoodItem(
            name: "Rice with Chicken",
            calories: "138 calories",
            image: "assets/images/curry_rice.png",
            time: "12:25 PM",
          ),
          FoodItem(
            name: "Water",
            calories: "0 calories",
            image: "assets/images/curry_rice.png",
            time: "12:40 PM",
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
            image: "assets/images/curry_rice.png",
            time: "6:50 PM",
          ),
          FoodItem(
            name: "Steamed Vegetables",
            calories: "90 calories",
            image: "assets/images/curry_rice.png",
            time: "6:55 PM",
          ),
          FoodItem(
            name: "Quinoa",
            calories: "150 calories",
            image: "assets/images/curry_rice.png",
            time: "7:00 PM",
          ),
        ],
      ),
    ];
  }

  // Add a new food item to a meal
  void addFoodItem(int mealIndex, FoodItem food) {
    final updatedMeals = [...state];
    updatedMeals[mealIndex].foods.add(food);
    updatedMeals[mealIndex].updateTotalCalories();
    state = updatedMeals;
  }

  // Remove a food item from a meal
  void removeFoodItem(int mealIndex, int foodIndex) {
    final updatedMeals = [...state];
    updatedMeals[mealIndex].foods.removeAt(foodIndex);
    updatedMeals[mealIndex].updateTotalCalories();
    state = updatedMeals;
  }

  // Update an existing food item
  void updateFoodItem(int mealIndex, int foodIndex, FoodItem updatedFood) {
    final updatedMeals = [...state];
    updatedMeals[mealIndex].foods[foodIndex] = updatedFood;
    updatedMeals[mealIndex].updateTotalCalories();
    state = updatedMeals;
  }

  // Get color for a meal type
  Color getMealColor(String mealName) {
    switch (mealName) {
      case "Breakfast":
        return Colors.green.shade200;
      case "Lunch":
        return Colors.orange.shade200;
      case "Dinner":
        return Colors.deepPurple.shade200;
      default:
        return Colors.blue.shade200;
    }
  }
}
