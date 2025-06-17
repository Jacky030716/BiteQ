import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:biteq/features/home_dashboard/models/food_item.dart';

class DetailPage extends StatelessWidget {
  final FoodItem foodItem;

  const DetailPage({
    super.key,
    required this.foodItem,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F3F7),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF5F3F7),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Food Details',
          style: TextStyle(
            color: Colors.black,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              height: 300,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.2),
                    spreadRadius: 2,
                    blurRadius: 10,
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Image.asset(
                  foodItem.imagePath,
                  fit: BoxFit.cover,
                ),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              foodItem.name,
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.1),
                    spreadRadius: 1,
                    blurRadius: 6,
                  ),
                ],
              ),
              child: Column(
                children: [
                  _NutritionRow('Calories', '${foodItem.calories}', 'kcal'),
                  const Divider(height: 24),
                  _NutritionRow('Protein', '${foodItem.protein}', 'g'),
                  const Divider(height: 24),
                  _NutritionRow('Carbs', '${foodItem.carbs}', 'g'),
                  const Divider(height: 24),
                  _NutritionRow('Fats', '${foodItem.fats}', 'g'),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.1),
                    spreadRadius: 1,
                    blurRadius: 6,
                  ),
                ],
              ),
              child: Row(
                children: [
                  Icon(Icons.access_time, color: Colors.grey[600], size: 20),
                  const SizedBox(width: 8),
                  Text(
                    'Scanned on ${foodItem.dateScanned.day}/${foodItem.dateScanned.month}/${foodItem.dateScanned.year} at ${foodItem.dateScanned.hour}:${foodItem.dateScanned.minute.toString().padLeft(2, '0')}',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            NavigateButton(route: '/explore', text: 'Explore More'),
          ],
        ),
      ),
    );
  }
}

class _NutritionRow extends StatelessWidget {
  final String label;
  final String value;
  final String unit;

  const _NutritionRow(this.label, this.value, this.unit);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: Colors.black87,
          ),
        ),
        Text(
          '$value $unit',
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
      ],
    );
  }
}

class NavigateButton extends StatelessWidget {
  final String route;
  final String text;

  const NavigateButton({super.key, required this.route, required this.text});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () {
          context.go(route);
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF8B5FBF),
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 0,
        ),
        child: Text(
          text,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}