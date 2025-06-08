import 'package:biteq/features/food_analysis/presentation/widgets/donut_macro.dart';
import 'package:flutter/material.dart';

class MealSummary extends StatelessWidget {
  const MealSummary({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.fromLTRB(24, 32, 24, 24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.all(Radius.circular(16)),
            border: Border.all(color: Colors.grey.shade300, width: 1),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.shade200,
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  _circularProgress("2,150 Cal", "150 left"),
                  const SizedBox(width: 40),
                  Column(
                    children: [
                      MacroDonut(
                        label: "Protein",
                        grams: "150g",
                        percent: "28%",
                        color: Colors.blue,
                        icon: Icons.local_dining,
                      ),
                      const SizedBox(height: 12),
                      MacroDonut(
                        label: "Carbs",
                        grams: "272g",
                        percent: "52%",
                        color: Colors.red,
                        icon: Icons.rice_bowl,
                      ),
                      const SizedBox(height: 12),

                      MacroDonut(
                        label: "Fat",
                        grams: "62g",
                        percent: "20%",
                        color: Colors.orangeAccent,
                        icon: Icons.local_pizza,
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 32),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildCaloriesInfo("2100", "Eaten", Icons.restaurant),
                  // const SizedBox(width: 30),
                  _buildCaloriesInfo("200", "Left", Icons.hourglass_bottom),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCaloriesInfo(String value, String label, IconData? icon) {
    final color = label == "Eaten" ? Colors.green : Colors.red;

    return Column(
      children: [
        Text(
          "$value Kcal",
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 2),
        Row(
          children: [
            Icon(icon, size: 12, color: color),
            const SizedBox(width: 2),
            Text(label, style: TextStyle(fontSize: 12, color: color)),
          ],
        ),
      ],
    );
  }

  Widget _circularProgress(String value, String label) {
    // Parse the value to a double for the progress indicator
    double parsedValue =
        double.tryParse(value.replaceAll(',', '').replaceAll(' Cal', '')) ??
        0.0;

    double progressValue = parsedValue / 2300;

    return Stack(
      alignment: Alignment.center,
      children: [
        TweenAnimationBuilder<double>(
          tween: Tween<double>(begin: 0, end: progressValue),
          duration: const Duration(seconds: 1), // Animation duration
          builder: (context, value, child) {
            return SizedBox(
              width: 150,
              height: 150,
              child: CircularProgressIndicator(
                value: value,
                strokeCap: StrokeCap.round,
                strokeWidth: 12,
                backgroundColor: Colors.grey.shade300,
                valueColor: AlwaysStoppedAnimation<Color>(
                  progressValue > 0.5 ? Colors.blue : Colors.lightBlue,
                ),
              ),
            );
          },
        ),
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.local_fire_department, size: 32, color: Colors.red),
            const SizedBox(height: 4),
            Text(
              value,
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
            ),
            Text(label, style: TextStyle(fontSize: 14)),
          ],
        ),
      ],
    );
  }
}
