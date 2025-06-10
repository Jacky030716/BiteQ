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

  // Get numeric value of calories
  int get caloriesValue {
    // Extract numeric value from calories string
    RegExp regExp = RegExp(r'\d+');
    Match? match = regExp.firstMatch(calories);
    if (match != null) {
      return int.parse(match.group(0)!);
    }
    return 0;
  }

  // Set calories with proper formatting
  set caloriesValue(int value) {
    calories = '$value calories';
  }

  // Create from json
  factory FoodItem.fromJson(Map<String, dynamic> json) {
    return FoodItem(
      name: json['name'] ?? '',
      calories: json['calories'] ?? '0 calories',
      image: json['image'] ?? '',
      time: json['time'] ?? '',
    );
  }

  // Convert to json
  Map<String, dynamic> toJson() {
    return {'name': name, 'calories': calories, 'image': image, 'time': time};
  }

  // Copy with method for easy updates
  FoodItem copyWith({
    String? name,
    String? calories,
    String? image,
    String? time,
  }) {
    return FoodItem(
      name: name ?? this.name,
      calories: calories ?? this.calories,
      image: image ?? this.image,
      time: time ?? this.time,
    );
  }

  // Override toString for debugging
  @override
  String toString() {
    return 'FoodItem(name: $name, calories: $calories, image: $image, time: $time)';
  }

  // Override equality operators
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is FoodItem &&
        other.name == name &&
        other.calories == calories &&
        other.image == image &&
        other.time == time;
  }

  @override
  int get hashCode {
    return name.hashCode ^ calories.hashCode ^ image.hashCode ^ time.hashCode;
  }
}
