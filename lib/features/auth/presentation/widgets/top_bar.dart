import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:biteq/core/theme/_app.Palette.dart';

class TopBar extends StatelessWidget implements PreferredSizeWidget {
  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
  const TopBar({super.key});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Palette.background,
      elevation: 0,
      centerTitle: true,
      title: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Image.asset('assets/images/logo.png', height: 20),
          const SizedBox(width: 4),
          Text(
            'BiteQ',
            style: TextStyle(
              fontWeight: FontWeight.w700,
              color: Palette.blackText,
              fontSize: 18,
            ),
          ),
        ],
      ),
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: Colors.black38, size: 18),
        onPressed: () {
          context.go('/onboarding');
        },
      ),
      bottom: const PreferredSize(
        preferredSize: Size.fromHeight(0),
        child: Divider(color: Colors.black12, height: 1),
      ),
    );
  }
}
