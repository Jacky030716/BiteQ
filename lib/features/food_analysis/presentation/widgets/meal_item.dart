import 'package:biteq/features/food_analysis/domain/entities/meals.dart';
import 'package:biteq/features/food_analysis/presentation/viewmodels/meal_view_model.dart';
import 'package:biteq/features/food_analysis/presentation/widgets/meal_item_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class MealItem extends ConsumerWidget {
  final int mealIndex;
  final Meal meal;
  final bool isLastMeal;
  final Function(int) onAddFood;
  final Function(int, int) onEditFood;

  const MealItem({
    super.key,
    required this.mealIndex,
    required this.meal,
    required this.isLastMeal,
    required this.onAddFood,
    required this.onEditFood,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final viewModel = ref.read(mealViewModelProvider.notifier);
    final mealColor = viewModel.getMealColor(meal.name);

    var totalCalsInInt = int.parse(meal.totalCals.split(' ')[0]);
    var totalCalsColor =
        totalCalsInInt > 500
            ? Colors.red
            : totalCalsInInt > 300
            ? Colors.orange
            : Colors.green;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Main meal header
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Image.asset(meal.mealIcon, width: 18, height: 18),
                  const SizedBox(width: 4),
                  Text(
                    meal.name,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
              Text(
                meal.totalCals,
                style: TextStyle(
                  color: totalCalsColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 8),

        // Food items container
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: Colors.grey.shade300, width: 1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: [
              // List of food items
              for (
                int foodIndex = 0;
                foodIndex < meal.foods.length;
                foodIndex++
              )
                FoodItemCard(
                  mealIndex: mealIndex,
                  foodIndex: foodIndex,
                  food: meal.foods[foodIndex],
                  mealColor: mealColor,
                  isLastFood: foodIndex == meal.foods.length - 1,
                  onEditFood: onEditFood,
                ),

              // Add more food button
              InkWell(
                onTap: () => onAddFood(mealIndex),
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(12),
                      bottomRight: Radius.circular(12),
                    ),
                  ),
                  child: Center(
                    child: Text(
                      "+ Add more food",
                      style: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),

        // Spacing between meals
        if (!isLastMeal) const SizedBox(height: 24),
      ],
    );
  }
}
