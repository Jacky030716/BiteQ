import 'food_item.dart';
import 'chart_data.dart';
import 'food_service_helper.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

// Main FoodService class - handles primary business logic
class FoodService {
  final FoodServiceHelpers _helpers = FoodServiceHelpers();
  
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
    final daysInMonth = DateTime(now.year, now.month + 1, 0).day;
    List<ChartData> monthlyData = [];

    for (int i = 1; i <= daysInMonth; i++) {
      double calories = 0;
      bool isToday = (i == now.day);

      if (i % 5 == 0) calories = 1500 + (i * 20.0);
      if (i % 7 == 0) calories = 2000 + (i * 15.0);
      if (i % 3 == 0) calories = 1000 + (i * 10.0);
      if (i == now.day) calories = 2568;

      monthlyData.add(ChartData(label: i.toString(), calories: calories, isToday: isToday));
    }
    return monthlyData;
  }

  // READ - Get all food items from Firestore
  Future<List<FoodItem>> getAllFoodItems() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return [];

    final uid = user.uid;
    final now = DateTime.now();
    final todayKey = "${now.year.toString().padLeft(4, '0')}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}";

    final mealTypesSnapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('meals_by_date')
        .doc(todayKey)
        .collection('mealTypes')
        .get();

    List<FoodItem> allItems = [];

    for (var doc in mealTypesSnapshot.docs) {
      final data = doc.data();
      final List<dynamic> foods = data['foods'] ?? [];

      for (var food in foods) {
        allItems.add(FoodItem(
          id: food['id'] ?? '',
          name: food['name'] ?? '',
          calories: _helpers.parseToDouble(food['calories']).toInt(),
          protein: _helpers.parseToDouble(food['protein']),
          carbs: _helpers.parseToDouble(food['carbs']),
          fats: _helpers.parseToDouble(food['fat']),
          dateScanned: _helpers.parseDateFromTimeString(food['time']) ?? now,
          imagePath: food['image'] ?? '',
        ));
      }
    }

    return allItems;
  }

  Future<FoodItem?> getFoodItemById(String id) async {
    await Future.delayed(const Duration(milliseconds: 300));
    try {
      return _foodItems.firstWhere((item) => item.id == id);
    } catch (e) {
      return null;
    }
  }

  Future<List<ChartData>> getChartData(String period) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return [];

    DateTime now = DateTime.now();
    final allItems = await getAllFoodItems();

    if (period == 'Day') {
      return _helpers.aggregateHourlyCalories(allItems, now);
    } else if (period == 'Week') {
      return _helpers.aggregateDailyCaloriesForWeek(allItems, now);
    } else if (period == 'Month') {
      return _helpers.aggregateDailyCaloriesForMonth(allItems, now);
    }

    return [];
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