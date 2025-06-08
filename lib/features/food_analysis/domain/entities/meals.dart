import 'package:biteq/features/food_analysis/domain/entities/food_item.dart';

class Meal {
  String name;
  String time;
  String mealIcon;
  String totalCals;
  List<FoodItem> foods;

  Meal({
    required this.name,
    required this.time,
    required this.mealIcon,
    required this.totalCals,
    required this.foods,
  });

  // Calculate total calories
  void updateTotalCalories() {
    int total = 0;
    for (var food in foods) {
      total += food.caloriesValue;
    }
    totalCals = "$total Cals";
  }

  // Create from json
  factory Meal.fromJson(Map<String, dynamic> json) {
    List<FoodItem> foodList = [];
    if (json['foods'] != null) {
      for (var food in json['foods']) {
        foodList.add(FoodItem.fromJson(food));
      }
    }

    return Meal(
      name: json['name'] ?? '',
      mealIcon: json['mealIcon'] ?? '',
      time: json['time'] ?? '',
      totalCals: json['totalCals'] ?? '0 Cals',
      foods: foodList,
    );
  }

  // Convert to json
  Map<String, dynamic> toJson() {
    List<Map<String, dynamic>> foodsJson = [];
    for (var food in foods) {
      foodsJson.add(food.toJson());
    }

    return {
      'name': name,
      'mealIcon': mealIcon,
      'time': time,
      'totalCals': totalCals,
      'foods': foodsJson,
    };
  }
}
