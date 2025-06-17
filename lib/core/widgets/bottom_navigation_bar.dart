import 'package:flutter/material.dart';

class FoodTrackingBottomNav extends StatefulWidget {
  final int currentIndex;
  final Function(int) onTap;

  const FoodTrackingBottomNav({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  State<FoodTrackingBottomNav> createState() => _FoodTrackingBottomNavState();
}

class _FoodTrackingBottomNavState extends State<FoodTrackingBottomNav>
    with TickerProviderStateMixin {
  late AnimationController _floatingButtonController;
  late Animation<double> _floatingButtonAnimation;

  @override
  void initState() {
    super.initState();
    _floatingButtonController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _floatingButtonAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(
        parent: _floatingButtonController,
        curve: Curves.easeInOut,
      ),
    );
  }

  @override
  void dispose() {
    _floatingButtonController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 90,
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Main navigation bar
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              height: 80,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  // Home
                  _buildNavItem(
                    icon: Icons.home_outlined,
                    activeIcon: Icons.home,
                    label: 'Home',
                    index: 0,
                  ),
                  // Meals/Food Log
                  _buildNavItem(
                    icon: Icons.post_add_outlined,
                    activeIcon: Icons.post_add,
                    label: 'Posts',
                    index: 1,
                  ),
                  // Spacer for floating button
                  const SizedBox(width: 60),
                  // Analysis
                  _buildNavItem(
                    icon: Icons.analytics_outlined,
                    activeIcon: Icons.analytics,
                    label: 'Analysis',
                    index: 3,
                  ),
                  // Profile
                  _buildNavItem(
                    icon: Icons.person_outline,
                    activeIcon: Icons.person,
                    label: 'Profile',
                    index: 4,
                  ),
                ],
              ),
            ),
          ),
          // Floating Camera Button
          Positioned(
            left: MediaQuery.of(context).size.width / 2 - 30,
            top: 10,
            child: GestureDetector(
              onTapDown: (_) => _floatingButtonController.forward(),
              onTapUp: (_) {
                _floatingButtonController.reverse();
                widget.onTap(2);
              },
              onTapCancel: () => _floatingButtonController.reverse(),
              child: AnimatedBuilder(
                animation: _floatingButtonAnimation,
                builder: (context, child) {
                  return Transform.scale(
                    scale: _floatingButtonAnimation.value,
                    child: Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Colors.blue.shade400, Colors.blue.shade600],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.blue.withOpacity(0.3),
                            blurRadius: 15,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.camera_alt,
                        color: Colors.white,
                        size: 26,
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem({
    required IconData icon,
    required IconData activeIcon,
    required String label,
    required int index,
  }) {
    final isActive = widget.currentIndex == index;

    return GestureDetector(
      onTap: () => widget.onTap(index),
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color:
                    isActive
                        ? Colors.blue.withOpacity(0.1)
                        : Colors.transparent,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Icon(
                isActive ? activeIcon : icon,
                color: isActive ? Colors.blue.shade600 : Colors.grey.shade600,
                size: 24,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
                color: isActive ? Colors.blue.shade600 : Colors.grey.shade600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
