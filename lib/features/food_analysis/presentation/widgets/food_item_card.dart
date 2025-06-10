// ignore_for_file: deprecated_member_use

import 'package:biteq/features/food_analysis/domain/entities/food_item.dart';
import 'package:flutter/material.dart';

class FoodItemCard extends StatelessWidget {
  final int mealIndex;
  final int foodIndex;
  final FoodItem food;
  final Color mealColor;
  final bool isLastFood;
  final Function(int, int) onEditFood;
  final Function(int, int)? onDeleteFood;

  const FoodItemCard({
    super.key,
    required this.mealIndex,
    required this.foodIndex,
    required this.food,
    required this.mealColor,
    required this.isLastFood,
    required this.onEditFood,
    this.onDeleteFood,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border:
            isLastFood
                ? null
                : Border(
                  bottom: BorderSide(color: Colors.grey.shade100, width: 1),
                ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => onEditFood(mealIndex, foodIndex),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Food image or placeholder
                _buildFoodImage(context),

                const SizedBox(width: 14),

                // Food details
                Expanded(child: _buildFoodDetails(context)),

                const SizedBox(width: 12),

                // Actions
                _buildActions(context),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFoodImage(BuildContext context) {
    return Container(
      width: 56,
      height: 56,
      decoration: BoxDecoration(
        color: mealColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: mealColor.withOpacity(0.2), width: 1.5),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10.5),
        child: Image.asset(
          "assets/images/curry_rice.png",
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return _buildFoodPlaceholder();
          },
        ),
      ),
    );
  }

  Widget _buildFoodPlaceholder() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [mealColor.withOpacity(0.1), mealColor.withOpacity(0.05)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Icon(Icons.restaurant, color: mealColor, size: 28),
    );
  }

  Widget _buildFoodDetails(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          food.name,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: Colors.grey.shade800,
            fontSize: 16,
          ),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 2),

        Text(
          food.calories,
          style: TextStyle(
            color: Colors.orange.shade600,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(width: 8),
        if (food.time.isNotEmpty) ...[
          Text(
            food.time,
            style: TextStyle(
              color: Colors.grey.shade500,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],

        // Time row with proper alignment (if time exists)
      ],
    );
  }

  Widget _buildActions(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Edit button
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: Colors.blue.shade50,
            borderRadius: BorderRadius.circular(8),
          ),
          child: IconButton(
            onPressed: () => onEditFood(mealIndex, foodIndex),
            icon: Icon(
              Icons.edit_outlined,
              color: Colors.blue.shade600,
              size: 18,
            ),
            tooltip: 'Edit food item',
            constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
            padding: const EdgeInsets.all(6),
          ),
        ),

        // Delete button (if callback provided)
        if (onDeleteFood != null) ...[
          const SizedBox(width: 8),
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Colors.red.shade50,
              borderRadius: BorderRadius.circular(8),
            ),
            child: IconButton(
              onPressed: () => onDeleteFood!(mealIndex, foodIndex),
              icon: Icon(
                Icons.delete_outline,
                color: Colors.red.shade600,
                size: 18,
              ),
              tooltip: 'Delete food item',
              constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
              padding: const EdgeInsets.all(6),
            ),
          ),
        ],
      ],
    );
  }
}
