import 'food_item.dart';
import 'chart_data.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

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

  List<ChartData> _aggregateHourlyCalories(List<FoodItem> items, DateTime now) {
  List<ChartData> hourly = [];

  for (int hour = 0; hour < 24; hour += 2) {
    final start = DateTime(now.year, now.month, now.day, hour);
    final end = start.add(const Duration(hours: 2));

    double totalCalories = items
      .where((item) => item.dateScanned.isAfter(start) && item.dateScanned.isBefore(end))
      .fold(0.0, (sum, item) => sum + item.calories);

    hourly.add(ChartData(
      label: hour.toString(),
      calories: totalCalories,
      isToday: hour <= now.hour && hour + 2 > now.hour,
    ));
  }

  return hourly;
}

double _parseToDouble(dynamic value) {
  if (value == null) return 0.0;
  if (value is num) return value.toDouble();
  if (value is String) {
    // Extract numeric part from strings like "450 calories"
    final cleaned = RegExp(r'\d+(\.\d+)?').stringMatch(value);
    return double.tryParse(cleaned ?? '0') ?? 0.0;
  }
  return 0.0;
}

DateTime? _parseDateFromTimeString(String? timeString) {
  if (timeString == null) return null;

  final now = DateTime.now();
  try {
    final timeParts = timeString.split(RegExp(r'[: ]'));
    int hour = int.parse(timeParts[0]);
    int minute = int.parse(timeParts[1]);
    final amPm = timeParts[2];

    if (amPm == 'PM' && hour != 12) hour += 12;
    if (amPm == 'AM' && hour == 12) hour = 0;

    return DateTime(now.year, now.month, now.day, hour, minute);
  } catch (e) {
    return null;
  }
}


List<ChartData> _aggregateDailyCaloriesForWeek(List<FoodItem> items, DateTime now) {
  List<ChartData> weekly = [];

  DateTime startOfWeek = now.subtract(Duration(days: now.weekday - 1));
  for (int i = 0; i < 7; i++) {
    final day = startOfWeek.add(Duration(days: i));

    double totalCalories = items
      .where((item) => item.dateScanned.year == day.year &&
                       item.dateScanned.month == day.month &&
                       item.dateScanned.day == day.day)
      .fold(0.0, (sum, item) => sum + item.calories);

    weekly.add(ChartData(
      label: _getWeekdayLabel(day.weekday),
      calories: totalCalories,
      isToday: now.day == day.day && now.month == day.month,
    ));
  }

  return weekly;
}

List<ChartData> _aggregateDailyCaloriesForMonth(List<FoodItem> items, DateTime now) {
  int daysInMonth = DateTime(now.year, now.month + 1, 0).day;
  List<ChartData> monthly = [];

  for (int i = 1; i <= daysInMonth; i++) {
    double totalCalories = items
      .where((item) => item.dateScanned.year == now.year &&
                       item.dateScanned.month == now.month &&
                       item.dateScanned.day == i)
      .fold(0.0, (sum, item) => sum + item.calories);

    monthly.add(ChartData(
      label: i.toString(),
      calories: totalCalories,
      isToday: now.day == i,
    ));
  }

  return monthly;
}

String _getWeekdayLabel(int weekday) {
  const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
  return days[weekday - 1];
}


  // READ
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
        calories: _parseToDouble(food['calories']).toInt(),
        protein: _parseToDouble(food['protein']),
        carbs: _parseToDouble(food['carbs']),
        fats: _parseToDouble(food['fat']),
        dateScanned: _parseDateFromTimeString(food['time']) ?? now,
 // or parse if needed
        imagePath: food['image'] ?? '', // ✅ Add this line
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

  // 1. Get all food items from Firestore
  final allItems = await getAllFoodItems();

  if (period == 'Day') {
    return _aggregateHourlyCalories(allItems, now);
  } else if (period == 'Week') {
    return _aggregateDailyCaloriesForWeek(allItems, now);
  } else if (period == 'Month') {
    return _aggregateDailyCaloriesForMonth(allItems, now);
  }

  return [];
}


String _getChartLabel(DateTime date, String period) {
  if (period == 'Week') {
    return _getWeekdayLabel(date.weekday);
  } else if (period == 'Month') {
    return date.day.toString();
  } else if (period == 'Day') {
    return date.hour.toString(); // not really used in this case
  } else {
    return '';
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