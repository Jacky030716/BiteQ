import 'food_item.dart';
import 'chart_data.dart';
import 'food_service_helper.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

// Main FoodService class - handles primary business logic
class FoodService {
  final FoodServiceHelpers _helpers = FoodServiceHelpers();

  Future<List<FoodItem>> getAllFoodItems() async {
    final end = DateTime.now();
    final start = end.subtract(const Duration(days: 30));
    return await fetchFoodItemsForDateRange(start, end);
  }

  Future<List<FoodItem>> fetchFoodItemsForDateRange(
    DateTime start,
    DateTime end,
  ) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return [];

    final uid = user.uid;
    final dateFormat = DateFormat('yyyy-MM-dd');
    List<FoodItem> allItems = [];

    // Loop through each day in the range
    for (
      DateTime date = start;
      !date.isAfter(end);
      date = date.add(const Duration(days: 1))
    ) {
      final dateKey = dateFormat.format(date);

      final mealTypesSnapshot =
          await FirebaseFirestore.instance
              .collection('users')
              .doc(uid)
              .collection('meals_by_date')
              .doc(dateKey)
              .collection('mealTypes')
              .get();

      for (var doc in mealTypesSnapshot.docs) {
        final data = doc.data();
        final List<dynamic> foods = data['foods'] ?? [];

        for (var food in foods) {
          allItems.add(
            FoodItem(
              id: food['id'] ?? '',
              name: food['name'] ?? '',
              calories: _helpers.parseToDouble(food['calories']).toInt(),
              protein: _helpers.parseToDouble(food['protein']),
              carbs: _helpers.parseToDouble(food['carbs']),
              fats: _helpers.parseToDouble(food['fat']),
              imagePath: food['image'] ?? '',
              dateScanned:
                  _helpers.parseDateFromTimeString(food['time'], date) ?? date,
            ),
          );
        }
      }
    }

    return allItems;
  }

  Future<FoodItem?> getFoodItemById(String id) async {
    final items = await getAllFoodItems();
    try {
      return items.firstWhere((item) => item.id == id);
    } catch (e) {
      return null;
    }
  }

  Future<List<ChartData>> getChartData(String period) async {
    DateTime now = DateTime.now();

    if (period == 'Day') {
      final items = await fetchFoodItemsForDateRange(now, now);
      return _helpers.aggregateHourlyCalories(items, now);
    } else if (period == 'Week') {
      final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
      final endOfWeek = startOfWeek.add(const Duration(days: 6));
      final items = await fetchFoodItemsForDateRange(startOfWeek, endOfWeek);
      return _helpers.aggregateDailyCaloriesForWeek(items, now);
    } else if (period == 'Month') {
      final startOfMonth = DateTime(now.year, now.month, 1);
      final endOfMonth = DateTime(now.year, now.month + 1, 0);
      final items = await fetchFoodItemsForDateRange(startOfMonth, endOfMonth);
      return _helpers.aggregateDailyCaloriesForMonth(items, now);
    }

    return [];
  }

  Future<List<ChartData>> getWeeklyChartData() async {
    final now = DateTime.now();
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
    final endOfWeek = startOfWeek.add(const Duration(days: 6));

    final items = await fetchFoodItemsForDateRange(startOfWeek, endOfWeek);
    return _helpers.aggregateDailyCaloriesForWeek(items, now);
  }

  Future<List<ChartData>> getMonthlyChartData() async {
    final now = DateTime.now();
    final startOfMonth = DateTime(now.year, now.month, 1);
    final endOfMonth = DateTime(now.year, now.month + 1, 0);

    final items = await fetchFoodItemsForDateRange(startOfMonth, endOfMonth);
    return _helpers.aggregateDailyCaloriesForMonth(items, now);
  }

  // Get total nutrition for today
  Future<Map<String, double>> getTodayNutrition() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return {};

    final uid = user.uid;
    final now = DateTime.now();
    final todayKey =
        "${now.year.toString().padLeft(4, '0')}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}";

    final mealTypesSnapshot =
        await FirebaseFirestore.instance
            .collection('users')
            .doc(uid)
            .collection('meals_by_date')
            .doc(todayKey)
            .collection('mealTypes')
            .get();

    double totalCalories = 0;
    double totalProtein = 0;
    double totalCarbs = 0;
    double totalFats = 0;

    for (var doc in mealTypesSnapshot.docs) {
      final data = doc.data();
      final List<dynamic> foods = data['foods'] ?? [];

      for (var food in foods) {
        // Handle both string ("450 calories") and numeric inputs
        String calStr = (food['calories'] ?? '').toString();
        double cal = 0;
        if (calStr.contains('calories')) {
          cal = double.tryParse(calStr.split(' ').first) ?? 0;
        } else {
          cal = double.tryParse(calStr) ?? 0;
        }

        totalCalories += cal;
        totalProtein += _helpers.parseToDouble(food['protein']);
        totalCarbs += _helpers.parseToDouble(food['carbs']);
        totalFats += _helpers.parseToDouble(food['fat']);
      }
    }

    return {
      'calories': totalCalories,
      'protein': totalProtein,
      'carbs': totalCarbs,
      'fats': totalFats,
    };
  }

  Future<Map<String, double>> getNutritionForDateRange(
    DateTime start,
    DateTime end,
  ) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return {};

    final uid = user.uid;
    final dateFormat = DateFormat('yyyy-MM-dd');
    double totalCalories = 0;
    double totalProtein = 0;
    double totalCarbs = 0;
    double totalFats = 0;

    for (
      DateTime date = start;
      !date.isAfter(end);
      date = date.add(const Duration(days: 1))
    ) {
      final dateKey = dateFormat.format(date);

      final mealTypesSnapshot =
          await FirebaseFirestore.instance
              .collection('users')
              .doc(uid)
              .collection('meals_by_date')
              .doc(dateKey)
              .collection('mealTypes')
              .get();

      for (var doc in mealTypesSnapshot.docs) {
        final data = doc.data();
        final List<dynamic> foods = data['foods'] ?? [];

        for (var food in foods) {
          totalCalories += _helpers.parseToDouble(food['calories']);
          totalProtein += _helpers.parseToDouble(food['protein']);
          totalCarbs += _helpers.parseToDouble(food['carbs']);
          totalFats += _helpers.parseToDouble(food['fat']);
        }
      }
    }

    return {
      'calories': totalCalories,
      'protein': totalProtein,
      'carbs': totalCarbs,
      'fats': totalFats,
    };
  }

  Future<double> getTotalWeeklyCalories() async {
    final now = DateTime.now();
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
    final endOfWeek = startOfWeek.add(const Duration(days: 6));

    final nutrition = await getNutritionForDateRange(startOfWeek, endOfWeek);
    return nutrition['calories'] ?? 0;
  }

  Future<double> getTotalMonthlyCalories() async {
    final now = DateTime.now();
    final startOfMonth = DateTime(now.year, now.month, 1);
    final endOfMonth = DateTime(now.year, now.month + 1, 0);

    final nutrition = await getNutritionForDateRange(startOfMonth, endOfMonth);
    return nutrition['calories'] ?? 0;
  }
}
