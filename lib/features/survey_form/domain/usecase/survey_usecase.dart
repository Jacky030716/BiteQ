import 'package:biteq/features/survey_form/data/models/user_survey.dart';
import 'package:biteq/features/survey_form/data/repositories/survey_repositories.dart';

class SurveyUsecase {
  final SurveyRepositories repository;

  SurveyUsecase(this.repository);

  Future submitSurvey(UserSurveyModel survey) async {
    final result = await repository.submitSurvey(survey);

    return result;
  }

  Future<bool> getSurveyStatus(String email) async {
    final status = await repository.getSurveyStatus(email);

    return status;
  }
}
