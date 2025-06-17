import 'food_item.dart';
import 'chart_data.dart';

// Helper class for FoodService - contains utility methods and data aggregation logic
class FoodServiceHelpers {
  
  // Utility method to parse various input types to double
  double parseToDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is num) return value.toDouble();
    if (value is String) {
      // Extract numeric part from strings like "450 calories"
      final cleaned = RegExp(r'\d+(\.\d+)?').stringMatch(value);
      return double.tryParse(cleaned ?? '0') ?? 0.0;
    }
    return 0.0;
  }

  // Parse time string to DateTime
  DateTime? parseDateFromTimeString(String? timeString) {
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

  // Aggregate calories by hour for daily view
  List<ChartData> aggregateHourlyCalories(List<FoodItem> items, DateTime now) {
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

  // Aggregate calories by day for weekly view
  List<ChartData> aggregateDailyCaloriesForWeek(List<FoodItem> items, DateTime now) {
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
        label: getWeekdayLabel(day.weekday),
        calories: totalCalories,
        isToday: now.day == day.day && now.month == day.month,
      ));
    }

    return weekly;
  }

  // Aggregate calories by day for monthly view
  List<ChartData> aggregateDailyCaloriesForMonth(List<FoodItem> items, DateTime now) {
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

  // Get weekday label from weekday number
  String getWeekdayLabel(int weekday) {
    const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return days[weekday - 1];
  }

  // Get chart label based on date and period
  String getChartLabel(DateTime date, String period) {
    if (period == 'Week') {
      return getWeekdayLabel(date.weekday);
    } else if (period == 'Month') {
      return date.day.toString();
    } else if (period == 'Day') {
      return date.hour.toString();
    } else {
      return '';
    }
  }
}