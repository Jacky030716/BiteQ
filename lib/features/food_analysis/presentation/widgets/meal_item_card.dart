import 'package:biteq/features/food_analysis/domain/entities/food_item.dart';
import 'package:biteq/features/food_analysis/presentation/viewmodels/meal_view_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class FoodItemCard extends ConsumerWidget {
  final int mealIndex;
  final int foodIndex;
  final FoodItem food;
  final Color mealColor;
  final bool isLastFood;
  final Function(int, int) onEditFood;

  const FoodItemCard({
    super.key,
    required this.mealIndex,
    required this.foodIndex,
    required this.food,
    required this.mealColor,
    required this.isLastFood,
    required this.onEditFood,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final viewModel = ref.read(mealViewModelProvider.notifier);

    return Dismissible(
      key: Key("$mealIndex-$foodIndex-${food.name}"),
      background: Container(
        color: Colors.red.shade400,
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      direction: DismissDirection.endToStart,
      onDismissed: (direction) {
        viewModel.removeFoodItem(mealIndex, foodIndex);
      },
      child: InkWell(
        onTap: () => onEditFood(mealIndex, foodIndex),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            border:
                !isLastFood
                    ? Border(bottom: BorderSide(color: Colors.grey.shade200))
                    : null,
          ),
          child: Row(
            children: [
              // Food icon
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Image.asset(
                    food.image,
                    width: double.infinity,
                    height: double.infinity,
                    fit: BoxFit.cover,
                  ),
                ),
              ),

              const SizedBox(width: 16),

              // Food details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      food.name,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
                    ),
                    Text(
                      food.calories,
                      style: TextStyle(color: Colors.blueGrey, fontSize: 14),
                    ),
                  ],
                ),
              ),

              // Time consumed
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    food.time,
                    style: TextStyle(
                      color: Colors.blueGrey,
                      fontWeight: FontWeight.w500,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Icon(Icons.edit_outlined, size: 16, color: Colors.black),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
