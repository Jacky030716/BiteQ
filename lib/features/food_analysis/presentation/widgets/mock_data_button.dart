import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:biteq/features/food_analysis/domain/entities/meals.dart';
import 'package:biteq/features/food_analysis/domain/entities/food_item.dart';

class MockDataButton extends ConsumerWidget {
  final Function() onDataAdded; // Callback to refresh the UI after adding data

  const MockDataButton({super.key, required this.onDataAdded});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      margin: const EdgeInsets.all(16),
      child: ElevatedButton.icon(
        onPressed: () => _addMockMeals(context, ref),
        icon: const Icon(Icons.add_circle_outline),
        label: const Text('Add Mock Data'),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.blue.shade600,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 2,
        ),
      ),
    );
  }

  Future<void> _addMockMeals(BuildContext context, WidgetRef ref) async {
    try {
      // Show loading indicator
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(child: CircularProgressIndicator()),
      );

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
              image: 'assets/images/curry_rice.png',
              time: '07:31 AM',
            ),
            FoodItem(
              name: 'Toast',
              calories: '120 Cals',
              image: 'assets/images/curry_rice.png',
              time: '07:32 AM',
            ),
            FoodItem(
              name: 'Orange Juice',
              calories: '150 Cals',
              image: 'assets/images/curry_rice.png',
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
              image: 'assets/images/curry_rice.png',
              time: '12:46 PM',
            ),
            FoodItem(
              name: 'Grilled Chicken',
              calories: '250 Cals',
              image: 'assets/images/curry_rice.png',
              time: '12:47 PM',
            ),
            FoodItem(
              name: 'Salad',
              calories: '80 Cals',
              image: 'assets/images/curry_rice.png',
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
              image: 'assets/images/curry_rice.png',
              time: '07:01 PM',
            ),
            FoodItem(
              name: 'Meatballs',
              calories: '200 Cals',
              image: 'assets/images/curry_rice.png',
              time: '07:02 PM',
            ),
            FoodItem(
              name: 'Watermelon',
              calories: '50 Cals',
              image: 'assets/images/curry_rice.png',
              time: '07:03 PM',
            ),
          ],
        ),
      ];

      // Add meals to repository
      for (var meal in meals) {
        meal.updateTotalCalories(); // auto-calculate total
        // Replace this with your actual repository call
        // await _mealRepository.addMeal(meal);

        // Simulate API call delay
        await Future.delayed(const Duration(milliseconds: 100));
      }

      // Close loading dialog
      if (context.mounted) {
        Navigator.of(context).pop();

        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Mock data added successfully!'),
            backgroundColor: Colors.green.shade600,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        );

        // Trigger UI refresh
        onDataAdded();
      }
    } catch (e) {
      // Close loading dialog if still open
      if (context.mounted) {
        Navigator.of(context).pop();

        // Show error message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error adding mock data: $e'),
            backgroundColor: Colors.red.shade600,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        );
      }
    }
  }
}
