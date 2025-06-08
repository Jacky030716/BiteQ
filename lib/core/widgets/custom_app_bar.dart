import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:biteq/core/theme/_app.Palette.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final VoidCallback? onLeadingPressed;
  final Widget? leading;
  final bool showDivider;

  const CustomAppBar({
    super.key,
    required this.title,
    this.onLeadingPressed,
    this.leading,
    this.showDivider = true,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Palette.background,
      elevation: 0,
      centerTitle: true,
      title: Text(
        title,
        style: TextStyle(
          fontWeight: FontWeight.w700,
          color: Palette.blackText,
          fontSize: 18,
        ),
      ),
      // leading:
      //     leading ??
      //     IconButton(
      //       icon: const Icon(Icons.arrow_back, color: Colors.black38, size: 18),
      //       onPressed: onLeadingPressed ?? () => context.pop(),
      //     ),
      bottom:
          showDivider
              ? const PreferredSize(
                preferredSize: Size.fromHeight(0),
                child: Divider(color: Colors.black12, height: 1),
              )
              : null,
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
