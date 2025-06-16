import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:biteq/features/auth/presentation/viewmodel/sign_out_view_model.dart';
import 'package:go_router/go_router.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:biteq/features/home_dashboard/presentation/widgets/chart.dart'; // Import the new chart file

// Data Models
class FoodItem {
  final String id;
  final String name;
  final int calories;
  final double protein;
  final double carbs;
  final double fats;
  final DateTime dateScanned;
  final String imagePath;

  FoodItem({
    required this.id,
    required this.name,
    required this.calories,
    required this.protein,
    required this.carbs,
    required this.fats,
    required this.dateScanned,
    this.imagePath = 'assets/images/chicken_bolognese.jpg',
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'calories': calories,
      'protein': protein,
      'carbs': carbs,
      'fats': fats,
      'dateScanned': dateScanned.toIso8601String(),
      'imagePath': imagePath,
    };
  }

  factory FoodItem.fromJson(Map<String, dynamic> json) {
    return FoodItem(
      id: json['id'],
      name: json['name'],
      calories: json['calories'],
      protein: json['protein'].toDouble(),
      carbs: json['carbs'].toDouble(),
      fats: json['fats'].toDouble(),
      dateScanned: DateTime.parse(json['dateScanned']),
      imagePath: json['imagePath'] ?? 'assets/images/chicken_bolognese.jpg',
    );
  }
}

// Chart data for different time periods
class ChartData {
  final String label;
  final double calories;
  final bool isToday;

  ChartData({required this.label, required this.calories, this.isToday = false});
}

// Read-only Service
class FoodService {
  final List<FoodItem> _foodItems = [
    FoodItem(
      id: '1',
      name: 'Chicken Bolognese',
      calories: 275,
      protein: 70,
      carbs: 120,
      fats: 20,
      dateScanned: DateTime.now().subtract(const Duration(hours: 2)),
    ),
    FoodItem(
      id: '2',
      name: 'Grilled Salmon',
      calories: 350,
      protein: 45,
      carbs: 5,
      fats: 18,
      dateScanned: DateTime.now().subtract(const Duration(hours: 5)),
    ),
    FoodItem(
      id: '3',
      name: 'Vegetable Stir Fry',
      calories: 180,
      protein: 8,
      carbs: 25,
      fats: 7,
      dateScanned: DateTime.now().subtract(const Duration(days: 1)),
    ),
  ];

  // Mock daily data (24 hours)
  final List<ChartData> _dailyData = [
    ChartData(label: '6', calories: 0),
    ChartData(label: '8', calories: 150),
    ChartData(label: '10', calories: 0),
    ChartData(label: '12', calories: 450),
    ChartData(label: '14', calories: 0),
    ChartData(label: '16', calories: 275),
    ChartData(label: '18', calories: 625, isToday: true), // Current hour
    ChartData(label: '20', calories: 0),
    ChartData(label: '22', calories: 0),
  ];

  // Mock weekly data
  final List<ChartData> _weeklyData = [
    ChartData(label: 'Mon', calories: 1200),
    ChartData(label: 'Tue', calories: 1800),
    ChartData(label: 'Wed', calories: 1500),
    ChartData(label: 'Thu', calories: 2100),
    ChartData(label: 'Fri', calories: 2568, isToday: true), // Today
    ChartData(label: 'Sat', calories: 0),
    ChartData(label: 'Sun', calories: 0),
  ];

  // Mock monthly data (30-31 days)
  List<ChartData> _getMonthlyData() {
    final now = DateTime.now();
    final daysInMonth = DateTime(now.year, now.month + 1, 0).day; // Get last day of current month
    List<ChartData> monthlyData = [];

    // Simple mock data for each day of the month
    for (int i = 1; i <= daysInMonth; i++) {
      double calories = 0;
      bool isToday = (i == now.day); // Mark today's bar

      // Add some sample calories for certain days to make the chart interesting
      if (i % 5 == 0) calories = 1500 + (i * 20.0);
      if (i % 7 == 0) calories = 2000 + (i * 15.0);
      if (i % 3 == 0) calories = 1000 + (i * 10.0);
      if (i == now.day) calories = 2568; // Ensure today has a value

      monthlyData.add(ChartData(label: i.toString(), calories: calories, isToday: isToday));
    }
    return monthlyData;
  }

  // READ
  Future<List<FoodItem>> getAllFoodItems() async {
    await Future.delayed(const Duration(milliseconds: 300));
    return List.from(_foodItems);
  }

  Future<FoodItem?> getFoodItemById(String id) async {
    await Future.delayed(const Duration(milliseconds: 300));
    try {
      return _foodItems.firstWhere((item) => item.id == id);
    } catch (e) {
      return null;
    }
  }

  Future<List<ChartData>> getChartData(String timePeriod) async {
    await Future.delayed(const Duration(milliseconds: 300));
    switch (timePeriod) {
      case 'Day':
        return List.from(_dailyData);
      case 'Week':
        return List.from(_weeklyData);
      case 'Month':
        return _getMonthlyData(); // Call the new method for monthly data
      default:
        return List.from(_weeklyData);
    }
  }

  // Get total nutrition for today
  Future<Map<String, double>> getTodayNutrition() async {
    final today = DateTime.now();
    final todayItems = _foodItems.where((item) =>
      item.dateScanned.day == today.day &&
      item.dateScanned.month == today.month &&
      item.dateScanned.year == today.year
    ).toList();

    double totalCalories = 0;
    double totalProtein = 0;
    double totalCarbs = 0;
    double totalFats = 0;

    for (final item in todayItems) {
      totalCalories += item.calories;
      totalProtein += item.protein;
      totalCarbs += item.carbs;
      totalFats += item.fats;
    }

    return {
      'calories': totalCalories,
      'protein': totalProtein,
      'carbs': totalCarbs,
      'fats': totalFats,
    };
  }
}

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

void main() {
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: const HomeScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

// Time period selection provider
final selectedTimePeriodProvider = StateProvider<String>((ref) => 'Week');

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final signOutViewModel = ref.watch(signOutViewModelProvider.notifier);
    final foodItemsAsync = ref.watch(foodItemsProvider);
    final chartDataAsync = ref.watch(chartDataProvider);
    final todayNutritionAsync = ref.watch(todayNutritionProvider);
    final selectedTimePeriod = ref.watch(selectedTimePeriodProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF5F3F7),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF5F3F7),
        elevation: 0,
        automaticallyImplyLeading: false,
        title: const Text(
          'Activity',
          style: TextStyle(
            color: Colors.black,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.exit_to_app, color: Colors.black),
            onPressed: () {
              signOutViewModel.signOut(() => context.go('/sign-in'), ref);
            },
          ),
        ],
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
              child: Image.asset(
                foodItem.imagePath,
                width: 60,
                height: 60,
                fit: BoxFit.cover,
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

class DetailPage extends StatelessWidget {
  final FoodItem foodItem;

  const DetailPage({
    super.key,
    required this.foodItem,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F3F7),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF5F3F7),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Food Details',
          style: TextStyle(
            color: Colors.black,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              height: 300,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.2),
                    spreadRadius: 2,
                    blurRadius: 10,
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Image.asset(
                  foodItem.imagePath,
                  fit: BoxFit.cover,
                ),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              foodItem.name,
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(20),
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
              child: Column(
                children: [
                  _NutritionRow('Calories', '${foodItem.calories}', 'kcal'),
                  const Divider(height: 24),
                  _NutritionRow('Protein', '${foodItem.protein}', 'g'),
                  const Divider(height: 24),
                  _NutritionRow('Carbs', '${foodItem.carbs}', 'g'),
                  const Divider(height: 24),
                  _NutritionRow('Fats', '${foodItem.fats}', 'g'),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
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
                  Icon(Icons.access_time, color: Colors.grey[600], size: 20),
                  const SizedBox(width: 8),
                  Text(
                    'Scanned on ${foodItem.dateScanned.day}/${foodItem.dateScanned.month}/${foodItem.dateScanned.year} at ${foodItem.dateScanned.hour}:${foodItem.dateScanned.minute.toString().padLeft(2, '0')}',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            NavigateButton(route: '/explore', text: 'Explore More'),
          ],
        ),
      ),
    );
  }
}

class _NutritionRow extends StatelessWidget {
  final String label;
  final String value;
  final String unit;

  const _NutritionRow(this.label, this.value, this.unit);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: Colors.black87,
          ),
        ),
        Text(
          '$value $unit',
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
      ],
    );
  }
}

class NavigateButton extends StatelessWidget {
  final String route;
  final String text;

  const NavigateButton({super.key, required this.route, required this.text});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () {
          context.go(route);
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF8B5FBF),
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 0,
        ),
        child: Text(
          text,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}