import 'package:biteq/features/survey_form/data/models/user_survey.dart';

UserSurveyModel mapResponsesToUserSurvey(List<dynamic> responses) {
  String safeString(dynamic value) => value?.toString() ?? '';

  return UserSurveyModel(
    gender: safeString(responses[0]),
    age:
        responses[1] is int
            ? responses[1]
            : int.tryParse(responses[1]?.toString() ?? '') ?? 0,
    height:
        responses[2] is double
            ? responses[2]
            : double.tryParse(responses[2]?.toString() ?? '') ?? 0.0,
    weight:
        responses[3] is double
            ? responses[3]
            : double.tryParse(responses[3]?.toString() ?? '') ?? 0.0,
    activityLevel: safeString(responses[4]),
    dietaryPreferences: safeString(responses[5]),
    foodAllergies: safeString(responses[6]),
    goal: safeString(responses[7]),
    mealsPerDay: safeString(responses[8]),
    glassesOfWater: safeString(responses[9]),
  );
}
