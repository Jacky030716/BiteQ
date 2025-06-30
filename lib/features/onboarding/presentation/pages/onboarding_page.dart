import 'dart:async';

import 'package:biteq/core/navigation/app_router.dart';
import 'package:biteq/core/theme/_app.Palette.dart';
import 'package:biteq/features/onboarding/data/onboarding_items.dart';
import 'package:biteq/features/onboarding/presentation/widgets/onboarding_content.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class OnboardingPage extends ConsumerStatefulWidget {
  const OnboardingPage({super.key});

  @override
  ConsumerState<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends ConsumerState<OnboardingPage> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  Timer? _autoScrollTimer;

  @override
  void initState() {
    super.initState();
    _startAutoScroll();
  }

  @override
  void dispose() {
    _autoScrollTimer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  void _startAutoScroll() {
    _autoScrollTimer = Timer.periodic(const Duration(seconds: 3), (timer) {
      if (_currentPage < onboardingItems.length - 1) {
        _pageController.nextPage(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      } else {
        _pageController.animateToPage(
          0,
          duration: const Duration(milliseconds: 800),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  // Mark onboarding as displayed and navigate
  Future<void> _markOnboardingDisplayed(String destination) async {
    final authRepository = ref.read(authRepositoryProvider);
    await authRepository.setOnboardingDisplayed();

    if (mounted) {
      context.go(destination);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Palette.background,
        elevation: 0,
        title: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset('assets/images/logo.png', height: 24),
                SizedBox(width: 4),
                Text(
                  'BiteQ',
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    color: Palette.blackText,
                    fontSize: 20,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      backgroundColor: Palette.background,
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              height: 500,
              child: GestureDetector(
                onHorizontalDragEnd: (details) {
                  if (details.velocity.pixelsPerSecond.dx > 0) {
                    if (_currentPage > 0) {
                      _pageController.previousPage(
                        duration: const Duration(milliseconds: 200),
                        curve: Curves.easeInOut,
                      );
                    }
                  } else {
                    if (_currentPage < onboardingItems.length - 1) {
                      _pageController.nextPage(
                        duration: const Duration(milliseconds: 200),
                        curve: Curves.easeInOut,
                      );
                    }
                  }
                },
                child: PageView.builder(
                  controller: _pageController,
                  itemCount: onboardingItems.length,
                  onPageChanged: (int page) {
                    setState(() {
                      _currentPage = page;
                    });
                  },
                  itemBuilder: (context, index) {
                    final item = onboardingItems[index];
                    return OnboardingContent(item: item);
                  },
                ),
              ),
            ),

            Column(
              children: [
                Container(
                  width: double.infinity,
                  height: 45,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    color: Palette.primary,
                  ),
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Palette.transparent,
                      shadowColor: Palette.transparent,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    onPressed: () => _markOnboardingDisplayed('/sign-in'),
                    child: Text(
                      'Login',
                      style: TextStyle(color: Palette.whiteText, fontSize: 16),
                    ),
                  ),
                ),

                SizedBox(height: 8),

                SizedBox(
                  width: double.infinity,
                  height: 40,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Palette.transparent,
                      shadowColor: Palette.transparent,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    onPressed: () => _markOnboardingDisplayed('/sign-up'),
                    child: Text(
                      'Create account',
                      style: TextStyle(
                        color: Palette.primary,
                        fontWeight: FontWeight.w500,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 20),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
