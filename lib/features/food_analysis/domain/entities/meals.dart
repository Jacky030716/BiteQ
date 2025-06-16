import 'package:biteq/features/food_analysis/domain/entities/food_item.dart';

class Meal {
  String? id;
  String name;
  String mealIcon;
  String time;
  String totalCals;
  List<FoodItem> foods;
  DateTime date;

  Meal({
    this.id,
    required this.name,
    required this.mealIcon,
    required this.time,
    required this.totalCals,
    required this.foods,
    required this.date,
  }) {
    updateTotalCalories();
  }

  void updateTotalCalories() {
    int sum = 0;
    for (var food in foods) {
      sum += food.caloriesValue;
    }
    totalCals = "$sum Cals";
  }

  // Add fromJson and toJson methods for repository interaction (example)
  factory Meal.fromJson(Map<String, dynamic> json) {
    return Meal(
      id: json['id'] as String?,
      name: json['name'] as String,
      mealIcon: json['mealIcon'] as String,
      time: json['time'] as String,
      totalCals: json['totalCals'] as String,
      foods:
          (json['foods'] as List<dynamic>)
              .map((e) => FoodItem.fromJson(e as Map<String, dynamic>))
              .toList(),
      date: DateTime.parse(json['date'] as String), // Parse date string
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'mealIcon': mealIcon,
      'time': time,
      'totalCals': totalCals,
      'foods': foods.map((e) => e.toJson()).toList(),
      'date': date.toIso8601String(), // Store date as ISO 8601 string
    };
  }
}
