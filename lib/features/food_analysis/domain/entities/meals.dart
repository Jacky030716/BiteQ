import 'package:biteq/features/food_analysis/domain/entities/food_item.dart';

class Meal {
  String?
  id; // Can be used to store the Firestore document ID (which is meal.name in this structure)
  String name;
  String mealIcon;
  String time;
  String totalCals;
  List<FoodItem> foods;
  DateTime date; // Explicitly stores the date for this meal entry

  Meal({
    this.id, // Optional, will be set from Firestore doc.id upon retrieval
    required this.name,
    required this.mealIcon,
    required this.time,
    required this.totalCals,
    required this.foods,
    required this.date,
  }) {
    // Ensure id is set to name if not provided (for new meals before they have a Firestore ID)
    id = id ?? name;
    updateTotalCalories();
  }

  /// Recalculates the total calories for all food items in this meal.
  void updateTotalCalories() {
    int sum = 0;
    for (var food in foods) {
      sum += food.caloriesValue;
    }
    totalCals = "$sum Cals";
  }

  /// Creates a [Meal] object from a JSON map (e.g., from Firestore).
  factory Meal.fromJson(Map<String, dynamic> json) {
    return Meal(
      id: json['id'] as String?, // Map 'id' from Firestore document ID or data
      name: json['name'] as String,
      mealIcon: json['mealIcon'] as String,
      time: json['time'] as String,
      totalCals: json['totalCals'] as String,
      foods:
          (json['foods'] as List<dynamic>)
              .map((e) => FoodItem.fromJson(e as Map<String, dynamic>))
              .toList(),
      date: DateTime.parse(
        json['date'] as String,
      ), // Parse date string to DateTime
    );
  }

  /// Converts this [Meal] object into a JSON map (e.g., for Firestore).
  Map<String, dynamic> toJson() {
    return {
      'id': id, // Include id in JSON, though Firestore uses doc.id externally
      'name': name,
      'mealIcon': mealIcon,
      'time': time,
      'totalCals': totalCals,
      'foods': foods.map((e) => e.toJson()).toList(),
      'date':
          date.toIso8601String(), // Store date as ISO 8601 string for full precision
    };
  }

  /// Returns a new [Meal] instance with specific fields updated.
  /// Useful for immutable updates in Riverpod state management.
  Meal copyWith({
    String? id,
    String? name,
    String? mealIcon,
    String? time,
    String? totalCals,
    List<FoodItem>? foods,
    DateTime? date,
  }) {
    return Meal(
      id: id ?? this.id,
      name: name ?? this.name,
      mealIcon: mealIcon ?? this.mealIcon,
      time: time ?? this.time,
      totalCals: totalCals ?? this.totalCals,
      foods: foods ?? this.foods,
      date: date ?? this.date,
    );
  }

  // Override toString for debugging
  @override
  String toString() {
    return 'Meal(id: $id, name: $name, mealIcon: $mealIcon, time: $time, totalCals: $totalCals, foods: $foods, date: $date)';
  }

  // Override equality operators
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Meal &&
        other.id == id &&
        other.name == name &&
        other.mealIcon == mealIcon &&
        other.time == time &&
        other.totalCals == totalCals &&
        // Note: List equality requires careful implementation if order matters
        // For simplicity, we'll compare individual food items by content
        listEquals(
          other.foods,
          foods,
        ) && // Using listEquals for food comparison
        other.date == date;
  }

  // Helper for list equality (since List is mutable and direct == won't work)
  bool listEquals(List<FoodItem>? list1, List<FoodItem>? list2) {
    if (list1 == null || list2 == null) {
      return list1 == list2; // Both null or one null and one not
    }
    if (list1.length != list2.length) return false;
    for (int i = 0; i < list1.length; i++) {
      if (list1[i] != list2[i]) return false;
    }
    return true;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        name.hashCode ^
        mealIcon.hashCode ^
        time.hashCode ^
        totalCals.hashCode ^
        Object.hashAll(foods) ^ // Hash all food items
        date.hashCode;
  }
}
