import 'package:biteq/core/widgets/bottom_navigation_bar.dart';
import 'package:biteq/core/widgets/custom_app_bar.dart';
import 'package:biteq/features/food_analysis/presentation/widgets/analyze_date_selection.dart';
import 'package:biteq/features/food_analysis/presentation/widgets/meal_list.dart';
import 'package:biteq/features/food_analysis/presentation/widgets/meal_summary.dart';
import 'package:biteq/features/food_analysis/presentation/widgets/water_consumption.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class FoodAnalysisPage extends ConsumerStatefulWidget {
  const FoodAnalysisPage({super.key});

  @override
  ConsumerState<FoodAnalysisPage> createState() => _FoodAnalysisPageState();
}

class _FoodAnalysisPageState extends ConsumerState<FoodAnalysisPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: CustomAppBar(
        title: 'Food Analysis',
        // onLeadingPressed: () => context.go('/home'),
      ),
      body: Container(
        padding: const EdgeInsets.only(bottom: 16),

        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
          child: ListView(
            children: [
              const AnalyzeDateSelection(),
              MealSummary(),
              const SizedBox(height: 15),
              WaterConsumption(),
              const SizedBox(height: 15),
              MealList(),
            ],
          ),
        ),
      ),
    );
  }
}
