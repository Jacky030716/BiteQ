import 'package:flutter/material.dart';

class MacroDonut extends StatelessWidget {
  final String label;
  final String grams;
  final String percent;
  final Color color;
  final IconData icon;
  final double progressValue; // New field for linear progress

  const MacroDonut({
    super.key,
    required this.label,
    required this.grams,
    required this.percent,
    required this.color,
    required this.icon,
    required this.progressValue, // Make sure to pass this
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Icon(icon, size: 16, color: Colors.black87),
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
          tween: Tween<double>(
            begin: 0,
            end: progressValue.clamp(0.0, 1.0),
          ), // Clamp value
          duration: const Duration(seconds: 1),
          builder: (context, value, child) {
            return SizedBox(
              width: 70,
              height: 6,
              child: LinearProgressIndicator(
                value: value,
                borderRadius: BorderRadius.circular(30),
                backgroundColor: Colors.grey.shade300,
                valueColor: AlwaysStoppedAnimation<Color>(color),
              ),
            );
          },
        ),
        const SizedBox(height: 4),
        Text(
          // Display actual grams and assumed target
          "$grams/${label == 'Protein'
              ? '150g'
              : label == 'Carbs'
              ? '272g'
              : '62g'}",
          style: const TextStyle(fontSize: 12, color: Colors.grey),
        ),
      ],
    );
  }
}
