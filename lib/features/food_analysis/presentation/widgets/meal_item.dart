import 'package:biteq/features/food_analysis/domain/entities/meals.dart';
import 'package:biteq/features/food_analysis/presentation/viewmodels/meal_view_model.dart';
import 'package:biteq/features/food_analysis/presentation/widgets/food_item_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class MealItem extends ConsumerWidget {
  final int mealIndex;
  final Meal meal;
  final bool isLastMeal;
  final Function(int) onAddFood;
  final Function(int, int) onEditFood;
  final Function(int, int)? onDeleteFood; // Optional delete callback

  const MealItem({
    super.key,
    required this.mealIndex,
    required this.meal,
    required this.isLastMeal,
    required this.onAddFood,
    required this.onEditFood,
    this.onDeleteFood,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final viewModel = ref.read(mealViewModelProvider.notifier);
    final mealColor = viewModel.getMealColor(meal.name);

    // Parse total calories safely
    var totalCalsInInt = _parseCalories(meal.totalCals);
    var totalCalsColor = _getCalorieColor(totalCalsInInt);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Main meal header
          _buildMealHeader(context, totalCalsColor),

          const SizedBox(height: 8),

          // Food items container
          _buildFoodItemsContainer(context, mealColor),

          // Spacing between meals
          if (!isLastMeal) const SizedBox(height: 12),
        ],
      ),
    );
  }

  Widget _buildMealHeader(BuildContext context, Color totalCalsColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
            spreadRadius: 0,
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Meal icon with fallback
              _buildMealIcon(),
              const SizedBox(width: 14),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    meal.name,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: Colors.grey.shade800,
                      fontSize: 18,
                    ),
                  ),
                  if (meal.time.isNotEmpty)
                    Text(
                      meal.time,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.grey.shade500,
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                ],
              ),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: totalCalsColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.local_fire_department,
                      color: totalCalsColor,
                      size: 16,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      meal.totalCals,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        color: totalCalsColor,
                        fontWeight: FontWeight.w700,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '${meal.foods.length} item${meal.foods.length != 1 ? 's' : ''}',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.grey.shade500,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMealIcon() {
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            _getMealBackgroundColor(),
            _getMealBackgroundColor().withOpacity(0.8),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: _getMealBackgroundColor().withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: _buildDefaultMealIcon(),
    );
  }

  Widget _buildDefaultMealIcon() {
    IconData iconData;
    switch (meal.name.toLowerCase()) {
      case 'breakfast':
        iconData = Icons.free_breakfast;
        break;
      case 'lunch':
        iconData = Icons.lunch_dining;
        break;
      case 'dinner':
        iconData = Icons.dinner_dining;
        break;
      case 'snack':
        iconData = Icons.cookie;
        break;
      default:
        iconData = Icons.restaurant;
    }

    return Icon(iconData, color: Colors.white, size: 22);
  }

  Widget _buildFoodItemsContainer(BuildContext context, Color mealColor) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
            spreadRadius: 0,
          ),
        ],
      ),
      child: Column(
        children: [
          // List of food items
          if (meal.foods.isEmpty)
            _buildEmptyFoodState(context)
          else
            ...meal.foods.asMap().entries.map((entry) {
              int foodIndex = entry.key;
              var food = entry.value;
              return FoodItemCard(
                mealIndex: mealIndex,
                foodIndex: foodIndex,
                food: food,
                mealColor: mealColor,
                isLastFood: foodIndex == meal.foods.length - 1,
                onEditFood: onEditFood,
                onDeleteFood: onDeleteFood,
              );
            }).toList(),

          // Add more food button
          _buildAddFoodButton(context),
        ],
      ),
    );
  }

  Widget _buildEmptyFoodState(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              borderRadius: BorderRadius.circular(30),
            ),
            child: Icon(
              Icons.restaurant_menu,
              color: Colors.blue.shade400,
              size: 30,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'No food items yet',
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
              color: Colors.grey.shade700,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Add your first food item below',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Colors.grey.shade500,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAddFoodButton(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => onAddFood(mealIndex),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(16),
          bottomRight: Radius.circular(16),
        ),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 18),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Colors.blue.shade50,
                Colors.blue.shade100.withOpacity(0.5),
              ],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
            borderRadius: const BorderRadius.only(
              bottomLeft: Radius.circular(16),
              bottomRight: Radius.circular(16),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(2),
                decoration: BoxDecoration(
                  color: Colors.blue.shade600,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.add, color: Colors.white, size: 16),
              ),
              const SizedBox(width: 10),
              Text(
                "Add Food",
                style: TextStyle(
                  color: Colors.blue.shade700,
                  fontWeight: FontWeight.w700,
                  fontSize: 15,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Helper methods
  int _parseCalories(String totalCals) {
    try {
      return int.parse(totalCals.split(' ')[0]);
    } catch (e) {
      return 0;
    }
  }

  Color _getCalorieColor(int calories) {
    if (calories > 500) {
      return Colors.orange.shade600;
    } else if (calories > 300) {
      return Colors.orange.shade500;
    } else {
      return Colors.blue.shade600;
    }
  }

  Color _getMealBackgroundColor() {
    switch (meal.name.toLowerCase()) {
      case 'breakfast':
        return Colors.blue.shade600;
      case 'lunch':
        return Colors.green.shade600;
      case 'dinner':
        return Colors.purple.shade600;
      case 'snack':
        return Colors.orange.shade600;
      default:
        return Colors.blue.shade600;
    }
  }
}
