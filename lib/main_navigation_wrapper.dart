import 'package:biteq/features/ai_detection/presentation/pages/image_picker_page.dart';
import 'package:biteq/features/food_analysis/presentation/pages/food_analysis_page.dart';
import 'package:biteq/features/home_dashboard/presentation/pages/home_screen.dart';
import 'package:biteq/features/posting/explore_page.dart';
import 'package:biteq/features/profile/presentation/user_profile_page.dart';
import 'package:biteq/core/widgets/bottom_navigation_bar.dart';
import 'package:biteq/features/posting/post_controller.dart';
import 'package:flutter/material.dart';

class MainNavigationWrapper extends StatefulWidget {
  final PostController postController;

  const MainNavigationWrapper({super.key, required this.postController});

  @override
  State<MainNavigationWrapper> createState() => _MainNavigationWrapperState();
}

class _MainNavigationWrapperState extends State<MainNavigationWrapper> {
  int _currentIndex = 0;
  late final List<Widget> _screens;

  @override
  void initState() {
    super.initState();
    _screens = [
      const HomeScreen(),
      ExplorePage(postController: widget.postController),
      const ImagePickerPage(),
      const FoodAnalysisPage(),
      const UserProfileScreen(),
    ];
  }

  void _onNavBarTap(int index) {
    if (index == 2) {
      _handleCameraAction();
    } else {
      setState(() => _currentIndex = index);
    }
  }

  void _handleCameraAction() {
    setState(() => _currentIndex = 2);
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
