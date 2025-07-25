import 'package:biteq/features/ai_detection/presentation/pages/ai_detection_mobile.dart';
import 'package:biteq/features/posting/explore_page.dart';
import 'package:biteq/features/profile/presentation/user_profile_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:biteq/core/widgets/bottom_navigation_bar.dart';

// Page widgets
import "package:biteq/features/home_dashboard/presentation/pages/home_screen.dart";
import 'package:biteq/features/food_analysis/presentation/pages/food_analysis_page.dart';

class MainNavigationWrapper extends ConsumerStatefulWidget {
  const MainNavigationWrapper({super.key});

  @override
  ConsumerState<MainNavigationWrapper> createState() =>
      _MainNavigationWrapperState();
}

class _MainNavigationWrapperState extends ConsumerState<MainNavigationWrapper> {
  int _currentIndex = 0;

  // List of your main screens
  late final List<Widget> _screens;

  @override
  void initState() {
    super.initState();
    _screens = [
      const HomeScreen(), // Index 0 - Home
      const ExplorePage(), // Index 1 - Meals
      const ImagePickerPage(), // Index 2 - Camera
      const FoodAnalysisPage(), // Index 3 - Analysis
      const UserProfileScreen(), // Index 4 - Profile
    ];
  }

  void _onNavBarTap(int index) {
    if (index == 2) {
      _handleCameraAction();
    } else {
      setState(() {
        _currentIndex = index;
      });
    }
  }

  void _handleCameraAction() {
    setState(() {
      _currentIndex = 2;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _currentIndex, children: _screens),
      bottomNavigationBar: FoodTrackingBottomNav(
        currentIndex: _currentIndex,
        onTap: _onNavBarTap,
      ),
    );
  }
}

// Alternative approach using PageView for smoother transitions
class MainNavigationWrapperWithPageView extends ConsumerStatefulWidget {
  const MainNavigationWrapperWithPageView({super.key});

  @override
  ConsumerState<MainNavigationWrapperWithPageView> createState() =>
      _MainNavigationWrapperWithPageViewState();
}

class _MainNavigationWrapperWithPageViewState
    extends ConsumerState<MainNavigationWrapperWithPageView> {
  late PageController _pageController;
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onNavBarTap(int index) {
    if (index == 2) {
      _handleCameraAction();
    } else {
      setState(() {
        _currentIndex = index;
      });
      _pageController.animateToPage(
        index,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _handleCameraAction() {
    // Handle camera action
    setState(() {
      _currentIndex = 2;
    });
    _pageController.animateToPage(
      2,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
        controller: _pageController,
        onPageChanged: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        children: const [
          HomeScreen(),
          ExplorePage(),
          ImagePickerPage(),
          FoodAnalysisPage(),
          UserProfileScreen(),
        ],
      ),
      bottomNavigationBar: FoodTrackingBottomNav(
        currentIndex: _currentIndex,
        onTap: _onNavBarTap,
      ),
    );
  }
}
