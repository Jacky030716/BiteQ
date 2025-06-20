class FoodAnalysisReport {
  final String foodName;
  final String description;
  final double calories;
  final double carbs;
  final double protein;
  final double fats;
  final DateTime timestamp;
  final String? imageUrl;

  FoodAnalysisReport({
    required this.foodName,
    required this.description,
    required this.calories,
    required this.carbs,
    required this.protein,
    required this.fats,
    required this.timestamp,
    this.imageUrl,
  });

  // Convert to the format matching your Firestore structure
  Map<String, dynamic> toFirestoreMap() {
    return {
      'name': foodName,
      'calories': '${calories.toInt()} calories',
      'carbs': carbs.toInt(),
      'protein': protein.toInt(),
      'fat': fats.toInt(),
      'time': formatTime(timestamp),
      'image': imageUrl ?? '',
    };
  }

  String formatTime(DateTime dateTime) {
    int hour = dateTime.hour;
    int minute = dateTime.minute;
    String period = hour >= 12 ? 'PM' : 'AM';

    if (hour > 12) hour -= 12;
    if (hour == 0) hour = 12;

    return '$hour:${minute.toString().padLeft(2, '0')} $period';
  }

  factory FoodAnalysisReport.fromMap(Map<String, dynamic> map) {
    return FoodAnalysisReport(
      foodName: map['name'] as String,
      description: map['description'] as String? ?? '',
      calories: _parseCalories(map['calories']),
      carbs: (map['carbs'] as num?)?.toDouble() ?? 0.0,
      protein: (map['protein'] as num?)?.toDouble() ?? 0.0,
      fats: (map['fat'] as num?)?.toDouble() ?? 0.0,
      timestamp: DateTime.now(),
      imageUrl: map['image'] as String?,
    );
  }

  static double _parseCalories(dynamic calories) {
    if (calories is num) return calories.toDouble();
    if (calories is String) {
      final match = RegExp(r'(\d+)').firstMatch(calories);
      return match != null ? double.parse(match.group(1)!) : 0.0;
    }
    return 0.0;
  }
}
