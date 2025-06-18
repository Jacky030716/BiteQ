import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:biteq/features/home_dashboard/presentation/widgets/chart.dart';
import 'package:biteq/features/home_dashboard/models/food_item.dart';
import 'package:biteq/features/home_dashboard/models/chart_data.dart';
import 'package:biteq/features/home_dashboard/models/food_service.dart';
import 'package:biteq/features/home_dashboard/presentation/pages/detail_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

// Riverpod Providers
final foodServiceProvider = Provider<FoodService>((ref) => FoodService());

final foodItemsProvider = FutureProvider<List<FoodItem>>((ref) async {
  final foodService = ref.watch(foodServiceProvider);
  return await foodService.getAllFoodItems();
});

// Dynamic chart data provider that depends on selected time period
final chartDataProvider = FutureProvider<List<ChartData>>((ref) async {
  final foodService = ref.watch(foodServiceProvider);
  final selectedTimePeriod = ref.watch(selectedTimePeriodProvider);
  return await foodService.getChartData(selectedTimePeriod);
});

//calories sum based on period
final dynamicNutritionProvider = FutureProvider<Map<String, double>>((ref) async {
  final foodService = ref.watch(foodServiceProvider);
  final selectedPeriod = ref.watch(selectedTimePeriodProvider);

  if (selectedPeriod == 'Day') {
    return await foodService.getTodayNutrition();
  } else if (selectedPeriod == 'Week') {
    final now = DateTime.now();
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
    final endOfWeek = startOfWeek.add(const Duration(days: 6));
    return await foodService.getNutritionForDateRange(startOfWeek, endOfWeek);
  } else if (selectedPeriod == 'Month') {
    final now = DateTime.now();
    final startOfMonth = DateTime(now.year, now.month, 1);
    final endOfMonth = DateTime(now.year, now.month + 1, 0);
    return await foodService.getNutritionForDateRange(startOfMonth, endOfMonth);
  }

  return {}; // fallback
});


//fetch username
Future<String?> getUsername() async {
  final user = FirebaseAuth.instance.currentUser;

  if (user != null) {
    DocumentSnapshot userDoc = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .get();

    if (userDoc.exists) {
      return userDoc.get('name'); // or userDoc['name']
    }
  }
  return null;
}

// Time period selection provider
final selectedTimePeriodProvider = StateProvider<String>((ref) => 'Week');

//period labels/titles
final displayPeriodLabels = {
  'Day': 'Daily',
  'Week': 'Weekly',
  'Month': 'Monthly',
};


class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final foodItemsAsync = ref.watch(foodItemsProvider);
    final chartDataAsync = ref.watch(chartDataProvider);
    final nutritionAsync = ref.watch(dynamicNutritionProvider);
    final selectedTimePeriod = ref.watch(selectedTimePeriodProvider);
    final displayLabel = displayPeriodLabels[selectedTimePeriod] ?? selectedTimePeriod;

    return FutureBuilder<String?>(
      future: getUsername(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            backgroundColor: Color(0xFFF5F3F7),
            body: Center(child: CircularProgressIndicator()),
          );
        } else if (snapshot.hasError || !snapshot.hasData) {
          return const Scaffold(
            backgroundColor: Color(0xFFF5F3F7),
            body: Center(child: Text("Failed to load username")),
          );
        }

    return Scaffold(
      backgroundColor: const Color(0xFFF5F3F7),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF5F3F7),
        elevation: 0,
        automaticallyImplyLeading: false,
        title: Text(
          "Hello, ${snapshot.data}!",
          style: TextStyle(
            color: Colors.black,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: RefreshIndicator(
        // Added RefreshIndicator here for pull-to-refresh
        color: Colors.blue,
        onRefresh: () async {
          // Refresh all the data providers
          ref.invalidate(foodItemsProvider);
          ref.invalidate(chartDataProvider);
          ref.invalidate(dynamicNutritionProvider);
          
          // Wait for all providers to complete their refresh
          await Future.wait([
            ref.read(foodItemsProvider.future),
            ref.read(chartDataProvider.future),
            ref.read(dynamicNutritionProvider.future),
          ]);
        },
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Overview Section
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Overview',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                    GestureDetector(
                      onTap: () => _showTimePeriodBottomSheet(context, ref),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.1),
                              spreadRadius: 1,
                              blurRadius: 3,
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            Text(
                              selectedTimePeriod,
                              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                            ),
                            const SizedBox(width: 4),
                            Icon(Icons.keyboard_arrow_down, size: 16, color: Colors.grey[600]),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Calories Overview
                nutritionAsync.when(
                    data: (nutrition) => Row(
                      children: [
                        Text(
                          '${nutrition['calories']?.toInt() ?? 0}',

                        style: const TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '$displayLabel Calories',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Colors.black54,
                        ),
                      ),

                    ],
                  ),
                  loading: () => const CircularProgressIndicator(),
                  error: (error, stack) => Text('Error: $error'),
                ),
                const SizedBox(height: 8),

                // Date Range
                Text(
                  _getDateRangeText(selectedTimePeriod),
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 24),

                // Dynamic Chart - Now uses the new widget
                chartDataAsync.when(
                  data: (chartData) => CalorieBarChart(
                    chartData: chartData,
                    selectedTimePeriod: selectedTimePeriod,
                  ),
                  loading: () => const Center(child: CircularProgressIndicator()),
                  error: (error, stack) => Center(child: Text('Error: $error')),
                ),
                const SizedBox(height: 32),

                // Recently Scanned Section
                const Text(
                  'Recently Scanned',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 16),

                // Food Items List
                foodItemsAsync.when(
                  data: (foodItems) {
                    // Sort food items by dateScanned in descending order (latest first)
                    final sortedItems = [...foodItems]
                      ..sort((a, b) => b.dateScanned.compareTo(a.dateScanned));

                    // Take only the latest 3 items
                    final latestThree = sortedItems.take(3).toList();

                    return ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: latestThree.length,
                      itemBuilder: (context, index) {
                        return _ScannedItem(foodItem: latestThree[index]);
                      },
                    );
                  },
                  loading: () => const Center(child: CircularProgressIndicator()),
                  error: (error, stack) => Center(child: Text('Error: $error')),
                ),
              ],
            ),
          ),
        ),
      ),
    );
      },
    );
  }

void _showTimePeriodBottomSheet(BuildContext context, WidgetRef ref) {
  final currentValue = ref.read(selectedTimePeriodProvider);

  showModalBottomSheet(
    context: context,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    backgroundColor: Colors.transparent,
    builder: (context) {
      return StatefulBuilder(
        builder: (context, setState) {
          String selectedValue = currentValue;

          return Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            ),
            padding: const EdgeInsets.all(16),
            child: Theme(
              data: Theme.of(context).copyWith(
                unselectedWidgetColor: Colors.white,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: ['Day', 'Week', 'Month'].map((period) {
                  return RadioListTile<String>(
                    title: Text(
                      period,
                      style: const TextStyle(color: Colors.black),
                    ),
                    value: period,
                    groupValue: selectedValue,
                    activeColor: Colors.blue,
                    onChanged: (value) {
                      if (value != null) {
                        setState(() => selectedValue = value);
                        ref.read(selectedTimePeriodProvider.notifier).state = value;
                        Navigator.pop(context);
                      }
                    },
                  );
                }).toList(),
              ),
            ),
          );
        },
      );
    },
  );
}




  String _getDateRangeText(String timePeriod) {
    final now = DateTime.now();

    switch (timePeriod) {
      case 'Day':
        return '${now.day} ${_getMonthName(now.month)} ${now.year}';
      case 'Week':
        // Get the current day of the week (1 for Monday, 7 for Sunday)
        int currentWeekday = now.weekday;
        // Calculate the start of the week (Monday)
        final startOfWeek = now.subtract(Duration(days: currentWeekday - 1));
        // Calculate the end of the week (Sunday)
        final endOfWeek = startOfWeek.add(const Duration(days: 6));

        // Handle case where start and end month might be different
        if (startOfWeek.month == endOfWeek.month) {
          return '${startOfWeek.day} - ${endOfWeek.day} ${_getMonthName(now.month)} ${now.year}';
        } else {
          return '${startOfWeek.day} ${_getMonthName(startOfWeek.month)} - ${endOfWeek.day} ${_getMonthName(endOfWeek.month)} ${now.year}';
        }

      case 'Month':
        return '${_getMonthName(now.month)} ${now.year}';
      default:
        return '1 - 7 May 2024'; // Fallback or default
    }
  }

  String _getMonthName(int month) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return months[month - 1];
  }
}

class _ScannedItem extends StatelessWidget {
  final FoodItem foodItem;

  const _ScannedItem({
    required this.foodItem,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => DetailPage(foodItem: foodItem),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              spreadRadius: 1,
              blurRadius: 6,
            ),
          ],
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(
                foodItem.imagePath,
                width: 60,
                height: 60,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Icon(
                  Icons.broken_image,
                  size: 60,
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    foodItem.name,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${foodItem.calories} cal • ${foodItem.protein}g protein',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${foodItem.dateScanned.hour}:${foodItem.dateScanned.minute.toString().padLeft(2, '0')}',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[500],
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: Colors.grey[400],
            ),
          ],
        ),
      ),
    );
  }
}