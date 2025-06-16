import 'dart:io';

import 'package:biteq/features/food_analysis/domain/entities/food_item.dart';
import 'package:biteq/features/food_analysis/domain/entities/meals.dart'; // Import Meal
import 'package:biteq/features/food_analysis/presentation/viewmodels/meal_view_model.dart';
import 'package:biteq/features/food_analysis/presentation/widgets/dialog/add_food_dialog.dart';
import 'package:biteq/features/food_analysis/presentation/widgets/dialog/edit_food_dialog.dart';
import 'package:biteq/features/food_analysis/presentation/widgets/meal_item.dart';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class MealList extends ConsumerStatefulWidget {
  final List<Meal> meals; // Now receives meals directly

  const MealList({super.key, required this.meals}); // Constructor updated

  @override
  ConsumerState<MealList> createState() => _MealListState();
}

class _MealListState extends ConsumerState<MealList> {
  void _handleAddFood(String mealName) async {
    AddFoodDialog.show(context, mealName, (FoodItem foodItem, File? imageFile) {
      ref
          .read(mealViewModelProvider.notifier)
          .addFoodItem(mealName, foodItem, imageFile);
    });
  }

  void _handleEditFood(String mealName, int foodIndex) async {
    // Access meals directly from widget.meals
    final meal = widget.meals.firstWhere(
      (m) => m.name == mealName,
      orElse: () => throw Exception('Meal not found'),
    );

    if (foodIndex < 0 || foodIndex >= meal.foods.length) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Food item not found.'),
          backgroundColor: Colors.red.shade400,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
      return;
    }

    final food = meal.foods[foodIndex];

    EditFoodDialog.show(context, food, (FoodItem updatedFoodItem) {
      ref
          .read(mealViewModelProvider.notifier)
          .updateFoodItem(
            mealName,
            foodIndex,
            updatedFoodItem,
          ); // Pass mealName
    });
  }

  void _handleDeleteFood(String mealName, int foodIndex) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Text(
            'Delete Food Item',
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          content: const Text(
            'Are you sure you want to delete this food item?',
            style: TextStyle(color: Colors.black54),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              style: TextButton.styleFrom(
                foregroundColor: Colors.grey.shade600,
              ),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                ref
                    .read(mealViewModelProvider.notifier)
                    .removeFoodItem(mealName, foodIndex); // Pass mealName
                Navigator.of(context).pop();
              },
              style: TextButton.styleFrom(foregroundColor: Colors.red.shade600),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        border: Border.all(color: Colors.grey.shade300, width: 1),
        borderRadius: const BorderRadius.all(Radius.circular(16)),
      ),
      // Removed the internal mealsAsyncValue.when and SingleChildScrollView
      // as FoodAnalysisPage now handles the loading/error state and provides the data.
      // Also, FoodAnalysisPage's ListView provides the overall scrolling.
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Meals List
          // It now receives meals directly via its constructor
          ListView.builder(
            shrinkWrap: true,
            physics:
                const NeverScrollableScrollPhysics(), // Important: Prevents internal scrolling
            itemCount: widget.meals.length, // Use widget.meals
            itemBuilder: (context, mealIndex) {
              final meal = widget.meals[mealIndex];
              final isLastMeal = mealIndex == widget.meals.length - 1;

              return MealItem(
                mealIndex: mealIndex,
                meal: meal,
                isLastMeal: isLastMeal,
                onAddFood: (index) => _handleAddFood(meal.name),
                onEditFood:
                    (index, foodIndex) => _handleEditFood(meal.name, foodIndex),
                onDeleteFood:
                    (index, foodIndex) =>
                        _handleDeleteFood(meal.name, foodIndex),
              );
            },
          ),

          // Bottom padding
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}
