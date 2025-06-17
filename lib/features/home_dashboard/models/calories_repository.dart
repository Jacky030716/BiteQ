import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import '../models/chart_data.dart'; // Update the path as needed

class CaloriesRepository {
  final FirebaseFirestore firestore;
  final String userId;

  CaloriesRepository({required this.firestore, required this.userId});

  Future<List<ChartData>> fetchAllCaloriesGroupedByDate() async {
    final userMealsRef = firestore
        .collection('users')
        .doc(userId)
        .collection('meals_by_date');

    final mealsByDateSnapshot = await userMealsRef.get();

    Map<String, double> caloriesByDate = {};

    for (final doc in mealsByDateSnapshot.docs) {
      final dateKey = doc.id;

      final mealTypesRef = userMealsRef.doc(dateKey).collection('mealTypes');
      final mealTypesSnapshot = await mealTypesRef.get();

      for (final mealDoc in mealTypesSnapshot.docs) {
        final data = mealDoc.data();

        if (data.containsKey('foods') && data['foods'] is List) {
          final foods = List<Map<String, dynamic>>.from(data['foods']);

          for (final food in foods) {
            final caloriesStr = food['calories'] ?? '0';
            final parsedCalories = _parseCaloriesToDouble(caloriesStr);

            caloriesByDate.update(
              dateKey,
              (existing) => existing + parsedCalories,
              ifAbsent: () => parsedCalories,
            );
          }
        }
      }
    }

    // Convert map to List<ChartData>
    List<ChartData> chartData = caloriesByDate.entries.map((entry) {
      return ChartData(
        label: _formatDate(entry.key),
        calories: entry.value,
      );
    }).toList();

    chartData.sort((a, b) => a.label.compareTo(b.label));

    return chartData;
  }

  /// Parse a string like "600 calories" or "600 Cals" into a double
  double _parseCaloriesToDouble(String raw) {
    final numeric = RegExp(r'\d+(\.\d+)?');
    final match = numeric.firstMatch(raw);
    return match != null ? double.parse(match.group(0)!) : 0.0;
  }

  /// Format the date key like "2025-06-16" to "Jun 16"
  String _formatDate(String dateKey) {
    try {
      final date = DateTime.parse(dateKey);
      return DateFormat('MMM d').format(date);
    } catch (e) {
      return dateKey;
    }
  }
}
