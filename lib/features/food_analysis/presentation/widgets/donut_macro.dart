import 'package:flutter/material.dart';

class MacroDonut extends StatelessWidget {
  final String label;
  final String grams;
  final String percent;
  final Color color;
  final IconData icon;

  const MacroDonut({
    super.key,
    required this.label,
    required this.grams,
    required this.percent,
    required this.color,
    required this.icon,
  });

  double get progressValue {
    return double.parse(percent.replaceAll('%', '')) / 100;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Icon(
              icon,
              size: 16,
              color: Colors.black87, // Modern semi-transparent icon
            ),
            const SizedBox(width: 4),
            Text(
              label,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        TweenAnimationBuilder<double>(
          tween: Tween<double>(begin: 0, end: progressValue),
          duration: const Duration(seconds: 1), // Animation duration
          builder: (context, value, child) {
            return SizedBox(
              width: 70,
              height: 6,
              child: LinearProgressIndicator(
                value: value,
                // strokeWidth: 6,
                borderRadius: BorderRadius.circular(30),
                backgroundColor: Colors.grey.shade300,
                valueColor: AlwaysStoppedAnimation<Color>(color),
              ),
            );
          },
        ),
        const SizedBox(height: 4),
        Text(
          "$grams/200g",
          style: const TextStyle(fontSize: 12, color: Colors.grey),
        ),
      ],
    );
  }
}
