class FoodItem {
  String name;
  String calories;
  String image;
  String time;
  int? protein;
  int? carbs;
  int? fat;

  FoodItem({
    required this.name,
    required this.calories,
    required this.image,
    required this.time,
    this.protein,
    this.carbs,
    this.fat,
  });

  // Helper to parse calories string to int
  int get caloriesValue {
    final caloriesString = calories.replaceAll(RegExp(r'[^0-9]'), '');
    return int.tryParse(caloriesString) ?? 0;
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
      protein: json['protein'] as int?, // Parse protein
      carbs: json['carbs'] as int?, // Parse carbs
      fat: json['fat'] as int?, // Parse fat
    );
  }

  // Convert to json
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'calories': calories,
      'image': image,
      'time': time,
      'protein': protein, // Include protein
      'carbs': carbs, // Include carbs
      'fat': fat, // Include fat
    };
  }

  // Copy with method for easy updates
  FoodItem copyWith({
    String? name,
    String? calories,
    String? image,
    String? time,
    int? protein,
    int? carbs,
    int? fat,
  }) {
    return FoodItem(
      name: name ?? this.name,
      calories: calories ?? this.calories,
      image: image ?? this.image,
      time: time ?? this.time,
      protein: protein ?? this.protein,
      carbs: carbs ?? this.carbs,
      fat: fat ?? this.fat,
    );
  }

  // Override toString for debugging
  @override
  String toString() {
    return 'FoodItem(name: $name, calories: $calories, image: $image, time: $time, protein: $protein, carbs: $carbs, fat: $fat)';
  }

  // Override equality operators
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is FoodItem &&
        other.name == name &&
        other.calories == calories &&
        other.image == image &&
        other.time == time &&
        other.protein == protein &&
        other.carbs == carbs &&
        other.fat == fat;
  }

  @override
  int get hashCode {
    return name.hashCode ^
        calories.hashCode ^
        image.hashCode ^
        time.hashCode ^
        protein.hashCode ^
        carbs.hashCode ^
        fat.hashCode;
  }
}
