import 'package:cloud_firestore/cloud_firestore.dart';

class ProfileUser {
  final String email;
  final String name;
  final String? profileImageUrl;
  final SurveyResponses surveyResponses;
  final String? aiAnalysisNotes; // AI generated analysis notes
  final int? recommendedProtein; // New: Recommended daily protein in grams
  final int? recommendedCarbs; // New: Recommended daily carbohydrates in grams
  final int? recommendedFat; // New: Recommended daily fat in grams
  final int? recommendedCalories; // New: Recommended daily total calories

  ProfileUser({
    required this.email,
    required this.name,
    this.profileImageUrl,
    required this.surveyResponses,
    this.aiAnalysisNotes,
    this.recommendedProtein,
    this.recommendedCarbs,
    this.recommendedFat,
    this.recommendedCalories,
  });

  factory ProfileUser.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> snapshot,
    SnapshotOptions? options,
  ) {
    final data = snapshot.data();

    // Handle survey_responses field which might be stored as a List or a Map
    Map<String, dynamic> surveyDataMap = {};
    final dynamic surveyResponsesRaw = data?['survey_responses'];

    if (surveyResponsesRaw is Map<String, dynamic>) {
      surveyDataMap = surveyResponsesRaw;
    } else if (surveyResponsesRaw is List<dynamic> &&
        surveyResponsesRaw.isNotEmpty) {
      if (surveyResponsesRaw[0] is Map<String, dynamic>) {
        surveyDataMap = surveyResponsesRaw[0] as Map<String, dynamic>;
      } else {
        surveyDataMap = {}; // Fallback to an empty map
      }
    } else if (surveyResponsesRaw == null) {
      surveyDataMap = {}; // Provide an empty map
    } else {
      surveyDataMap = {}; // Fallback to an empty map
    }

    return ProfileUser(
      email: data?['email'] as String,
      name: data?['name'] as String,
      profileImageUrl: data?['profileImageUrl'] as String?,
      surveyResponses: SurveyResponses.fromJson(
        surveyDataMap,
      ), // Use the determined surveyDataMap
      aiAnalysisNotes: data?['aiAnalysisNotes'] as String?,
      recommendedProtein: data?['recommendedProtein'] as int?,
      recommendedCarbs: data?['recommendedCarbs'] as int?,
      recommendedFat: data?['recommendedFat'] as int?,
      recommendedCalories: data?['recommendedCalories'] as int?,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'email': email,
      'name': name,
      if (profileImageUrl != null) 'profileImageUrl': profileImageUrl,
      'survey_responses':
          surveyResponses.toJson(), // This saves as a direct map
      if (aiAnalysisNotes != null) 'aiAnalysisNotes': aiAnalysisNotes,
      if (recommendedProtein != null) 'recommendedProtein': recommendedProtein,
      if (recommendedCarbs != null) 'recommendedCarbs': recommendedCarbs,
      if (recommendedFat != null) 'recommendedFat': recommendedFat,
      if (recommendedCalories != null)
        'recommendedCalories': recommendedCalories,
    };
  }

  // Updated copyWith method to include new fields
  ProfileUser copyWith({
    String? email,
    String? name,
    String? profileImageUrl,
    SurveyResponses? surveyResponses,
    String? aiAnalysisNotes,
    int? recommendedProtein,
    int? recommendedCarbs,
    int? recommendedFat,
    int? recommendedCalories,
  }) {
    return ProfileUser(
      email: email ?? this.email,
      name: name ?? this.name,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      surveyResponses: surveyResponses ?? this.surveyResponses,
      aiAnalysisNotes: aiAnalysisNotes ?? this.aiAnalysisNotes,
      recommendedProtein: recommendedProtein ?? this.recommendedProtein,
      recommendedCarbs: recommendedCarbs ?? this.recommendedCarbs,
      recommendedFat: recommendedFat ?? this.recommendedFat,
      recommendedCalories: recommendedCalories ?? this.recommendedCalories,
    );
  }
}

class SurveyResponses {
  final String activityLevel;
  final int age;
  final String dietaryPreferences;
  final String foodAllergies;
  final String gender;
  final String glassesOfWater;
  final String goal;
  final double height; // Stored as double for precision
  final double weight; // Stored as double for precision
  final String mealsPerDay;

  SurveyResponses({
    required this.activityLevel,
    required this.age,
    required this.dietaryPreferences,
    required this.foodAllergies,
    required this.gender,
    required this.glassesOfWater,
    required this.goal,
    required this.height,
    required this.weight,
    required this.mealsPerDay,
  });

  factory SurveyResponses.fromJson(Map<String, dynamic> json) {
    return SurveyResponses(
      activityLevel: json['activityLevel'] as String,
      age: json['age'] as int,
      dietaryPreferences: json['dietaryPreferences'] as String,
      foodAllergies: json['foodAllergies'] as String,
      gender: json['gender'] as String,
      glassesOfWater: json['glassesOfWater'] as String,
      goal: json['goal'] as String,
      height: (json['height'] as num).toDouble(), // Cast num to double
      weight: (json['weight'] as num).toDouble(), // Cast num to double
      mealsPerDay: json['mealsPerDay'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'activityLevel': activityLevel,
      'age': age,
      'dietaryPreferences': dietaryPreferences,
      'foodAllergies': foodAllergies,
      'gender': gender,
      'glassesOfWater': glassesOfWater,
      'goal': goal,
      'height': height,
      'weight': weight,
      'mealsPerDay': mealsPerDay,
    };
  }

  // copyWith method for SurveyResponses
  SurveyResponses copyWith({
    String? activityLevel,
    int? age,
    String? dietaryPreferences,
    String? foodAllergies,
    String? gender,
    String? glassesOfWater,
    String? goal,
    double? height,
    double? weight,
    String? mealsPerDay,
  }) {
    return SurveyResponses(
      activityLevel: activityLevel ?? this.activityLevel,
      age: age ?? this.age,
      dietaryPreferences: dietaryPreferences ?? this.dietaryPreferences,
      foodAllergies: foodAllergies ?? this.foodAllergies,
      gender: gender ?? this.gender,
      glassesOfWater: glassesOfWater ?? this.glassesOfWater,
      goal: goal ?? this.goal,
      height: height ?? this.height,
      weight: weight ?? this.weight,
      mealsPerDay: mealsPerDay ?? this.mealsPerDay,
    );
  }
}
