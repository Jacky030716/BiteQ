import 'package:cloud_firestore/cloud_firestore.dart';

class FoodItem {
  final String id;
  final String name;
  final int calories;
  final double protein;
  final double carbs;
  final double fats;
  final String imagePath;
  final DateTime dateScanned; // Changed to DateTime

  FoodItem({
    required this.id,
    required this.name,
    required this.calories,
    required this.protein,
    required this.carbs,
    required this.fats,
    required this.imagePath,
    required this.dateScanned, // Updated to DateTime
  });

  // Factory constructor to create a FoodItem from a JSON map (e.g., from Firestore)
  factory FoodItem.fromJson(Map<String, dynamic> json, DateTime mealDate) {
    // Helper to parse double values from various formats (string, num, "XXX calories")
    double _parseValueToDouble(dynamic value) {
      if (value == null) return 0.0;
      if (value is num) return value.toDouble();
      if (value is String) {
        final String cleanedValue =
            value.toLowerCase().replaceAll('calories', '').trim();
        return double.tryParse(cleanedValue) ?? 0.0;
      }
      return 0.0;
    }

    // Helper to parse time string and combine with a base date
    DateTime _parseDateFromTimeString(dynamic timeString, DateTime baseDate) {
      if (timeString == null || timeString.toString().isEmpty) {
        return baseDate; // Fallback to just the base date if time is missing
      }
      try {
        final parts = timeString.toString().split(
          RegExp(r'[: ]'),
        ); // Split by : or space for AM/PM
        int hour = int.parse(parts[0]);
        int minute = int.parse(parts[1]);

        // Check for AM/PM part and adjust hour for 24-hour format
        if (parts.length > 2) {
          final amPm = parts[2].toUpperCase();
          if (amPm == 'PM' && hour != 12) hour += 12;
          if (amPm == 'AM' && hour == 12) hour = 0;
        }

        return DateTime(
          baseDate.year,
          baseDate.month,
          baseDate.day,
          hour,
          minute,
        );
      } catch (e) {
        print("Error parsing time string '$timeString': $e");
        return baseDate; // Return just the base date if parsing fails
      }
    }

    return FoodItem(
      id: json['id'] ?? '',
      name: json['name'] ?? 'Unknown Food',
      calories:
          _parseValueToDouble(
            json['caloriesValue'] ?? json['calories'],
          ).toInt(), // Handle both possible keys
      protein: _parseValueToDouble(json['protein']),
      carbs: _parseValueToDouble(json['carbs']),
      fats: _parseValueToDouble(json['fat']),
      imagePath:
          json['image'] ??
          'https://placehold.co/60x60/ADE8F4/0077B6?text=No+Img', // Placeholder if no image
      dateScanned: _parseDateFromTimeString(
        json['time'],
        mealDate,
      ), // Use helper for dateScanned
    );
  }

  // Method to convert a FoodItem to a JSON map (for Firestore storage)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'caloriesValue':
          calories, // Store as caloriesValue for consistency with original structure
      'protein': protein,
      'carbs': carbs,
      'fat': fats,
      'image': imagePath,
      'time':
          '${dateScanned.hour}:${dateScanned.minute.toString().padLeft(2, '0')}', // Store only time string
      // date information is implicitly handled by the meal_by_date collection structure
    };
  }
}
