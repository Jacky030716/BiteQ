import 'package:biteq/features/home_dashboard/presentation/pages/home_screen.dart';
import 'package:flutter/material.dart';

class DetailPage extends StatelessWidget {
  final String foodName;
  final String calories;
  final String protein;
  final String carbs;
  final String fats;
  final String date;

  const DetailPage({
    required this.foodName,
    required this.calories,
    required this.protein,
    required this.carbs,
    required this.fats,
    required this.date,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Food Details')),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Image.asset(
              'assets/images/chicken_bolognese.jpg',
              width: double.infinity,
              height: 300,
              fit: BoxFit.cover,
            ),
            const SizedBox(height: 20),
            Text(
              foodName,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            Text('Calories: $calories', style: const TextStyle(fontSize: 18)),
            const SizedBox(height: 10),
            Text('Protein: $protein', style: const TextStyle(fontSize: 18)),
            const SizedBox(height: 10),
            Text('Carbs: $carbs', style: const TextStyle(fontSize: 18)),
            const SizedBox(height: 10),
            Text('Fats: $fats', style: const TextStyle(fontSize: 18)),
            const SizedBox(height: 10),
            Text(
              'Date: $date',
              style: const TextStyle(fontSize: 14, color: Colors.grey),
            ),
            const SizedBox(height: 20),
            NavigateButton(route: '/explore', text: 'Explore'),
          ],
        ),
      ),
    );
  }
}
