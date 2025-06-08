import 'package:biteq/features/food_analysis/domain/entities/food_item.dart';
import 'package:biteq/features/food_analysis/presentation/widgets/dialog/add_food_dialog.dart';
import 'package:biteq/features/food_analysis/presentation/widgets/dialog/edit_food_dialog.dart';
import 'package:biteq/features/food_analysis/presentation/widgets/meal_item.dart';
import 'package:biteq/features/food_analysis/presentation/viewmodels/meal_view_model.dart';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class MealList extends ConsumerStatefulWidget {
  const MealList({super.key});

  @override
  ConsumerState<MealList> createState() => _MealListState();
}

class _MealListState extends ConsumerState<MealList> {
  void _handleAddFood(int mealIndex) {
    final mealName = ref.read(mealViewModelProvider)[mealIndex].name;

    AddFoodDialog.show(context, mealName, (FoodItem foodItem) {
      ref.read(mealViewModelProvider.notifier).addFoodItem(mealIndex, foodItem);
    });
  }

  void _handleEditFood(int mealIndex, int foodIndex) {
    final food = ref.read(mealViewModelProvider)[mealIndex].foods[foodIndex];

    EditFoodDialog.show(context, food, (FoodItem updatedFoodItem) {
      ref
          .read(mealViewModelProvider.notifier)
          .updateFoodItem(mealIndex, foodIndex, updatedFoodItem);
    });
  }

  @override
  Widget build(BuildContext context) {
    final meals = ref.watch(mealViewModelProvider);

    return SizedBox(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: meals.length,
            itemBuilder: (context, mealIndex) {
              final meal = meals[mealIndex];
              final isLastMeal = mealIndex == meals.length - 1;

              return MealItem(
                mealIndex: mealIndex,
                meal: meal,
                isLastMeal: isLastMeal,
                onAddFood: _handleAddFood,
                onEditFood: _handleEditFood,
              );
            },
          ),
        ],
      ),
    );
  }
}
