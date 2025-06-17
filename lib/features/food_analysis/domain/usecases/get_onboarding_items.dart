import 'package:biteq/features/onboarding/domain/entities/onboarding_item.dart';

class GetOnboardingItemsUseCase {
  List<OnboardingItem> call() {
    return [
      OnboardingItem(
        title: 'BiteQ',
        description: 'Makes eating healthy and staying fit easier than ever',
        imagePath: 'assets/images/onboarding_1.png',
      ),
      OnboardingItem(
        title: 'Snap And Identify',
        description:
            'Take a photo of your meal, and our AI will identify food items instantly',
        imagePath: 'assets/images/onboarding_2.png',
      ),
      OnboardingItem(
        title: 'Track Your Progress',
        description:
            'Log calories and macronutrients automatically to stay on top of your fitness goals',
        imagePath: 'assets/images/onboarding_3.png',
      ),
      OnboardingItem(
        title: 'Safe Eating Made Simple',
        description:
            'Log calories and macronutrients automatically to stay on top of your fitness goals',
        imagePath: 'assets/images/onboarding_4.png',
      ),
    ];
  }
}
