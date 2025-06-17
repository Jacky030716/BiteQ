class FoodItem {
  final String id;
  final String name;
  final int calories;
  final double protein;
  final double carbs;
  final double fats;
  final DateTime dateScanned;
  final String imagePath;

  FoodItem({
    required this.id,
    required this.name,
    required this.calories,
    required this.protein,
    required this.carbs,
    required this.fats,
    required this.dateScanned,
    this.imagePath = 'assets/images/chicken_bolognese.jpg',
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'calories': calories,
      'protein': protein,
      'carbs': carbs,
      'fats': fats,
      'dateScanned': dateScanned.toIso8601String(),
      'imagePath': imagePath,
    };
  }

  factory FoodItem.fromJson(Map<String, dynamic> json) {
    return FoodItem(
      id: json['id'],
      name: json['name'],
      calories: json['calories'],
      protein: json['protein'].toDouble(),
      carbs: json['carbs'].toDouble(),
      fats: json['fats'].toDouble(),
      dateScanned: DateTime.parse(json['dateScanned']),
      imagePath: json['imagePath'] ?? 'assets/images/chicken_bolognese.jpg',
    );
  }
}