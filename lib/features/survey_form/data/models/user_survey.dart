class UserSurveyModel {
  final String gender;
  final double height;
  final double weight;
  final int age;

  final String activityLevel;
  final String dietaryPreferences;
  final String foodAllergies;
  final String goal;
  final String mealsPerDay;
  final String glassesOfWater;

  UserSurveyModel({
    required this.gender,
    required this.height,
    required this.weight,
    required this.age,
    required this.activityLevel,
    required this.dietaryPreferences,
    required this.foodAllergies,
    required this.goal,
    required this.mealsPerDay,
    required this.glassesOfWater,
  });

  factory UserSurveyModel.fromJson(Map<String, dynamic> json) {
    return UserSurveyModel(
      gender: json['gender'],
      height: json['height'],
      weight: json['weight'],
      age: json['age'],
      activityLevel: json['activityLevel'],
      dietaryPreferences: json['dietaryPreferences'],
      foodAllergies: json['foodAllergies'],
      goal: json['goal'],
      mealsPerDay: json['mealsPerDay'],
      glassesOfWater: json['glassesOfWater'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'gender': gender,
      'height': height,
      'weight': weight,
      'age': age,
      'activityLevel': activityLevel,
      'dietaryPreferences': dietaryPreferences,
      'foodAllergies': foodAllergies,
      'goal': goal,
      'mealsPerDay': mealsPerDay,
      'glassesOfWater': glassesOfWater,
    };
  }
}
