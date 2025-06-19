import 'package:flutter/material.dart';
import 'package:biteq/features/home_dashboard/models/food_item.dart';
import 'package:biteq/features/home_dashboard/presentation/pages/detail_page.dart'; // Ensure DetailPage is imported

class ScannedItemCard extends StatelessWidget {
  final FoodItem foodItem;

  const ScannedItemCard({
    super.key, // Corrected super.key
    required this.foodItem,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // Using Navigator.push for navigating to a detail page is fine here,
        // as it's not part of the primary navigation tabs.
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => DetailPage(foodItem: foodItem),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
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
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(
                foodItem.imagePath,
                width: 60,
                height: 60,
                fit: BoxFit.cover,
                errorBuilder:
                    (context, error, stackTrace) => Icon(
                      Icons.broken_image,
                      size: 60,
                      color: Colors.grey.shade400, // Better error icon color
                    ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    foodItem.name,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${foodItem.calories} cal • ${foodItem.protein}g protein',
                    style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${foodItem.dateScanned.hour}:${foodItem.dateScanned.minute.toString().padLeft(2, '0')}',
                    style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                  ),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey[400]),
          ],
        ),
      ),
    );
  }
}
