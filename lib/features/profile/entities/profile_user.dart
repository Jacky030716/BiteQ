class ProfileUser {
  final String email;
  final String name;
  final String? profileImageUrl;
  final SurveyResponses surveyResponses;
  final String? aiAnalysisNotes;

  ProfileUser({
    required this.email,
    required this.name,
    this.profileImageUrl,
    required this.surveyResponses,
    this.aiAnalysisNotes,
  });

  // Factory constructor for creating a ProfileUser from a Firestore DocumentSnapshot data map
  factory ProfileUser.fromJson(Map<String, dynamic> json) {
    // Safely get profileImageUrl, it might be null or not exist
    final String? imageUrl = json['profileImageUrl'] as String?;

    final List<dynamic>? surveyResponsesList =
        json['survey_responses'] as List<dynamic>?;

    Map<String, dynamic> actualSurveyData = {};
    if (surveyResponsesList != null && surveyResponsesList.isNotEmpty) {
      actualSurveyData = surveyResponsesList[0] as Map<String, dynamic>;
    } else {
      throw Exception(
        'Survey responses data is missing or not in the expected format',
      );
    }

    return ProfileUser(
      email: json['email'] as String,
      name: json['name'] as String,
      profileImageUrl: imageUrl, // Can be null
      surveyResponses: SurveyResponses.fromJson(
        actualSurveyData,
      ), // Pass the inner map
      aiAnalysisNotes: json['aiAnalysisNotes'] as String?,
    );
  }

  // Method to convert a ProfileUser object to a JSON-like map for Firestore
  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'name': name,
      'profileImageUrl': profileImageUrl,
      // When saving, format survey_responses back to match the Firestore structure
      'survey_responses': {'0': surveyResponses.toJson()},
      'aiAnalysisNotes': aiAnalysisNotes,
    };
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
  final double height;
  final String
  mealsPerDay; // Changed 'mealsPerDay' to 'mealsPerDay' for clarity

  SurveyResponses({
    required this.activityLevel,
    required this.age,
    required this.dietaryPreferences,
    required this.foodAllergies,
    required this.gender,
    required this.glassesOfWater,
    required this.goal,
    required this.height,
    required this.mealsPerDay,
  });

  // Factory constructor for creating SurveyResponses from the actual survey data map
  factory SurveyResponses.fromJson(Map<String, dynamic> data) {
    return SurveyResponses(
      activityLevel: data['activityLevel'] as String,
      age: data['age'] as int,
      dietaryPreferences: data['dietaryPreferences'] as String,
      foodAllergies: data['foodAllergies'] as String,
      gender: data['gender'] as String,
      glassesOfWater: data['glassesOfWater'] as String,
      goal: data['goal'] as String,
      height:
          (data['height'] as num).toDouble(), // Handle num to double conversion
      mealsPerDay:
          data['mealsPerDay'] as String, // Use original key from Firestore
    );
  }

  // Method to convert SurveyResponses object to a JSON-like map for saving to Firestore
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
      'mealsPerDay': mealsPerDay, // Use original key for saving
    };
  }
}
