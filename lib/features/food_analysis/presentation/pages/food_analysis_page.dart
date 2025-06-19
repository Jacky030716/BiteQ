import 'package:biteq/core/widgets/custom_app_bar.dart';
import 'package:biteq/features/food_analysis/presentation/viewmodels/meal_view_model.dart';
import 'package:biteq/features/food_analysis/presentation/widgets/analyze_date_selection.dart';
import 'package:biteq/features/food_analysis/presentation/widgets/meal_list.dart';
import 'package:biteq/features/food_analysis/presentation/widgets/meal_summary.dart';
import 'package:biteq/features/food_analysis/presentation/widgets/no_meals_found_card.dart'; // NEW IMPORT
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class FoodAnalysisPage extends ConsumerStatefulWidget {
  const FoodAnalysisPage({super.key});

  @override
  ConsumerState<FoodAnalysisPage> createState() => _FoodAnalysisPageState();
}

class _FoodAnalysisPageState extends ConsumerState<FoodAnalysisPage> {
  // Initialize the selected date to today when the page loads
  // This ensures the ViewModel fetches data for today initially
  @override
  void initState() {
    super.initState();
    // Ensure the MealViewModel is initialized with today's date
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(selectedDateProvider.notifier).state = DateTime.now();
    });
  }

  @override
  Widget build(BuildContext context) {
    // Watch the mealViewModelProvider to handle loading and error states centrally
    final mealState = ref.watch(mealViewModelProvider);

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: CustomAppBar(
        title: 'Food Analysis',
        // onLeadingPressed: () => context.go('/home'),
      ),
      body: RefreshIndicator(
        // Added RefreshIndicator here for pull-to-refresh
        onRefresh: () => ref.read(mealViewModelProvider.notifier).refresh(),
        color: Colors.blue.shade600,
        child: Container(
          padding: const EdgeInsets.only(bottom: 16),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
            child: ListView(
              children: [
                // Always show the date selection
                const AnalyzeDateSelection(),
                // Show content based on meal state
                mealState.when(
                  loading:
                      () => SizedBox(
                        height: 200,
                        child: Center(
                          child: CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Colors.blue.shade600,
                            ),
                          ),
                        ),
                      ),
                  error:
                      (error, stackTrace) => Container(
                        margin: const EdgeInsets.symmetric(vertical: 20),
                        padding: const EdgeInsets.all(20),
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
                            Icon(
                              Icons.error_outline,
                              color: Colors.red.shade400,
                              size: 64,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Error loading meals',
                              style: Theme.of(
                                context,
                              ).textTheme.headlineSmall?.copyWith(
                                color: Colors.black87,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              error.toString(),
                              style: Theme.of(context).textTheme.bodyMedium
                                  ?.copyWith(color: Colors.black54),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 16),
                            ElevatedButton(
                              onPressed: () {
                                ref
                                    .read(mealViewModelProvider.notifier)
                                    .refresh();
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.blue.shade600,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 24,
                                  vertical: 12,
                                ),
                              ),
                              child: const Text('Retry'),
                            ),
                          ],
                        ),
                      ),
                  data: (meals) {
                    // Check if there are no meals for the selected date
                    if (meals.isEmpty) {
                      return const NoMealsFoundCard(); // Use the new widget here
                    }

                    return Column(
                      children: [
                        MealSummary(), // Pass meals directly
                        const SizedBox(height: 15),
                        MealList(meals: meals), // Pass meals directly
                      ],
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
