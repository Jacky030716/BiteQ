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

final todayNutritionProvider = FutureProvider<Map<String, double>>((ref) async {
  final foodService = ref.watch(foodServiceProvider);
  return await foodService.getTodayNutrition();
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

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    
    final foodItemsAsync = ref.watch(foodItemsProvider);
    final chartDataAsync = ref.watch(chartDataProvider);
    final todayNutritionAsync = ref.watch(todayNutritionProvider);
    final selectedTimePeriod = ref.watch(selectedTimePeriodProvider);

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
      body: SingleChildScrollView(
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
              todayNutritionAsync.when(
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
                    const Text(
                      'Total kcal',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey,
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
                data: (foodItems) => ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: foodItems.length,
                  itemBuilder: (context, index) {
                    final foodItem = foodItems[index];
                    return _ScannedItem(foodItem: foodItem);
                  },
                ),
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (error, stack) => Center(child: Text('Error: $error')),
              ),
            ],
          ),
        ),
      ),
    );
      },
    );
  }

  void _showTimePeriodBottomSheet(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                margin: const EdgeInsets.symmetric(vertical: 12),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const Padding(
                padding: EdgeInsets.all(16.0),
                child: Text(
                  'Select Time Period',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              _buildTimePeriodOption(context, ref, 'Day'),
              _buildTimePeriodOption(context, ref, 'Week'),
              _buildTimePeriodOption(context, ref, 'Month'),
              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTimePeriodOption(BuildContext context, WidgetRef ref, String period) {
    final selectedTimePeriod = ref.watch(selectedTimePeriodProvider);
    final isSelected = selectedTimePeriod == period;

    return InkWell(
      onTap: () {
        ref.read(selectedTimePeriodProvider.notifier).state = period;
        Navigator.pop(context);
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Row(
          children: [
            Icon(
              isSelected ? Icons.radio_button_checked : Icons.radio_button_unchecked,
              color: isSelected ? const Color(0xFF8B5FBF) : Colors.grey,
            ),
            const SizedBox(width: 12),
            Text(
              period,
              style: TextStyle(
                fontSize: 16,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                color: isSelected ? const Color(0xFF8B5FBF) : Colors.black87,
              ),
            ),
          ],
        ),
      ),
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