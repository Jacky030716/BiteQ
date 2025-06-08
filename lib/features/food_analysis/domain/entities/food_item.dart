class FoodItem {
  String name;
  String calories;
  String image;
  String time;

  FoodItem({
    required this.name,
    required this.calories,
    required this.image,
    required this.time,
  });

  // Convert calories string to int value
  int get caloriesValue {
    return int.tryParse(calories.split(' ')[0]) ?? 0;
  }

  // Clone the food item
  FoodItem clone() {
    return FoodItem(name: name, calories: calories, image: image, time: time);
  }

  // Create from json
  factory FoodItem.fromJson(Map<String, dynamic> json) {
    return FoodItem(
      name: json['name'] ?? '',
      calories: json['calories'] ?? '',
      image: json['image'] ?? '🍽️',
      time: json['time'] ?? '',
    );
  }

  // Convert to json
  Map<String, dynamic> toJson() {
    return {'name': name, 'calories': calories, 'image': image, 'time': time};
  }
}
