import 'package:biteq/features/food_analysis/presentation/viewmodels/meal_view_model.dart';
import 'package:biteq/features/food_analysis/presentation/widgets/donut_macro.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class MealSummary extends ConsumerWidget {
  const MealSummary({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch the mealViewModelProvider to get the current state of meals
    final mealState = ref.watch(mealViewModelProvider);

    return mealState.when(
      data: (meals) {
        // Calculate total calories and macros from the filtered meals
        final totalCalories =
            ref.read(mealViewModelProvider.notifier).getTotalDailyCalories();
        final proteinGrams =
            ref.read(mealViewModelProvider.notifier).getProteinGrams();
        final carbsGrams =
            ref.read(mealViewModelProvider.notifier).getCarbsGrams();
        final fatGrams = ref.read(mealViewModelProvider.notifier).getFatGrams();

        // Assuming a target of 2300 calories, 150g protein, 272g carbs, 62g fat
        const double targetCalories = 2300;
        const double targetProtein = 150;
        const double targetCarbs = 272;
        const double targetFat = 62;

        final proteinPercent = (proteinGrams / targetProtein * 100)
            .toStringAsFixed(0);
        final carbsPercent = (carbsGrams / targetCarbs * 100).toStringAsFixed(
          0,
        );
        final fatPercent = (fatGrams / targetFat * 100).toStringAsFixed(0);

        final caloriesLeft = targetCalories - totalCalories;
        final progressValue = totalCalories / targetCalories;

        return Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.fromLTRB(24, 32, 24, 24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: const BorderRadius.all(Radius.circular(16)),
                border: Border.all(color: Colors.grey.shade300, width: 1),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.shade200,
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // Display total calories consumed and remaining
                      _circularProgress(
                        "${totalCalories.toStringAsFixed(0)} Cal",
                        "${caloriesLeft.toStringAsFixed(0)} left",
                        progressValue,
                      ),
                      const SizedBox(width: 40),
                      Column(
                        children: [
                          // Display Protein Donut
                          MacroDonut(
                            label: "Protein",
                            grams: "${proteinGrams.toStringAsFixed(0)}g",
                            percent: "$proteinPercent%",
                            color: Colors.blue,
                            icon: Icons.local_dining,
                            progressValue: proteinGrams / targetProtein,
                          ),
                          const SizedBox(height: 12),
                          // Display Carbs Donut
                          MacroDonut(
                            label: "Carbs",
                            grams: "${carbsGrams.toStringAsFixed(0)}g",
                            percent: "$carbsPercent%",
                            color: Colors.red,
                            icon: Icons.rice_bowl,
                            progressValue: carbsGrams / targetCarbs,
                          ),
                          const SizedBox(height: 12),
                          // Display Fat Donut
                          MacroDonut(
                            label: "Fat",
                            grams: "${fatGrams.toStringAsFixed(0)}g",
                            percent: "$fatPercent%",
                            color: Colors.orangeAccent,
                            icon: Icons.local_pizza,
                            progressValue: fatGrams / targetFat,
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildCaloriesInfo(
                        totalCalories.toStringAsFixed(0),
                        "Eaten",
                        Icons.restaurant,
                      ),
                      _buildCaloriesInfo(
                        caloriesLeft.toStringAsFixed(0),
                        "Left",
                        Icons.hourglass_bottom,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => Center(child: Text('Error: $error')),
    );
  }

  // Helper widget for displaying calories info
  Widget _buildCaloriesInfo(String value, String label, IconData? icon) {
    final color = label == "Eaten" ? Colors.green : Colors.red;

    return Column(
      children: [
        Text(
          "$value Kcal",
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 2),
        Row(
          children: [
            Icon(icon, size: 12, color: color),
            const SizedBox(width: 2),
            Text(label, style: TextStyle(fontSize: 12, color: color)),
          ],
        ),
      ],
    );
  }

  // Helper widget for circular progress indicator
  Widget _circularProgress(String value, String label, double progressValue) {
    return Stack(
      alignment: Alignment.center,
      children: [
        TweenAnimationBuilder<double>(
          tween: Tween<double>(
            begin: 0,
            end: progressValue.clamp(0.0, 1.0),
          ), // Clamp value between 0 and 1
          duration: const Duration(seconds: 1), // Animation duration
          builder: (context, value, child) {
            return SizedBox(
              width: 150,
              height: 150,
              child: CircularProgressIndicator(
                value: value,
                strokeCap: StrokeCap.round,
                strokeWidth: 12,
                backgroundColor: Colors.grey.shade300,
                valueColor: AlwaysStoppedAnimation<Color>(
                  progressValue > 0.5 ? Colors.blue : Colors.lightBlue,
                ),
              ),
            );
          },
        ),
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.local_fire_department, size: 32, color: Colors.red),
            const SizedBox(height: 4),
            Text(
              value,
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
            ),
            Text(label, style: TextStyle(fontSize: 14)),
          ],
        ),
      ],
    );
  }
}
