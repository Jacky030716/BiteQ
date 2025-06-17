import 'package:biteq/core/theme/_app.Palette.dart';
import 'package:biteq/features/onboarding/domain/entities/onboarding_item.dart';
import 'package:flutter/material.dart';

class OnboardingContent extends StatelessWidget {
  final OnboardingItem item;

  const OnboardingContent({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            item.title,
            style: TextStyle(
              fontSize: 40,
              fontWeight: FontWeight.w800,
              color: Palette.primary,
              height: 1.1,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 5),
          Text(
            item.description,
            style: TextStyle(fontSize: 16, color: Palette.placeholder),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 10),

          Image.asset(item.imagePath, height: 280, fit: BoxFit.contain),
        ],
      ),
    );
  }
}
