import 'package:biteq/features/food_analysis/presentation/viewmodels/meal_view_model.dart';
import 'package:biteq/features/food_analysis/presentation/widgets/dialog/add_food_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class NoMealsFoundCard extends ConsumerWidget {
  const NoMealsFoundCard({super.key});

  /// Determines the appropriate meal name (Breakfast, Lunch, Dinner, Snack)
  /// based on the current hour of the day.
  String _getMealNameBasedOnTime(TimeOfDay currentTime) {
    final hour = currentTime.hour;
    if (hour >= 5 && hour < 12) {
      return 'Breakfast';
    } else if (hour >= 12 && hour < 17) {
      return 'Lunch';
    } else if (hour >= 17 && hour < 22) {
      return 'Dinner';
    } else {
      return 'Snack'; // Default to snack for late night/early morning
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 20),
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.restaurant_menu, color: Colors.blue.shade200, size: 64),
          const SizedBox(height: 16),
          Text(
            'No meals found for this day',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: Colors.black87,
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            'Tap "Add Meal" to start tracking your food intake.',
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: Colors.black54),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () {
              // Determine meal name dynamically based on current time
              final suggestedMealName = _getMealNameBasedOnTime(
                TimeOfDay.now(),
              );

              AddFoodDialog.show(context, suggestedMealName, (
                foodItem,
                imageFile,
              ) {
                ref
                    .read(mealViewModelProvider.notifier)
                    .addFoodItem(suggestedMealName, foodItem, imageFile);
              });
            },
            icon: const Icon(Icons.add_circle_outline),
            label: const Text('Add Meal'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue.shade600,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
          ),
        ],
      ),
    );
  }
}
