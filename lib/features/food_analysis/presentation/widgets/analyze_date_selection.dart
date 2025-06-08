import 'package:flutter/material.dart';

class AnalyzeDateSelection extends StatelessWidget {
  const AnalyzeDateSelection({super.key});

  String _getWeekdayAbbr(DateTime date) {
    const weekdays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return weekdays[date.weekday - 1];
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 80,
      margin: const EdgeInsets.symmetric(vertical: 16),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: List.generate(7, (index) {
            final today = DateTime.now();
            final date = today.subtract(Duration(days: 6 - index));
            final isSelected = index == 6; // Highlight today by default

            return GestureDetector(
              onTap: () {
                // Handle date selection
              },
              child: Container(
                width: 50,
                margin: const EdgeInsets.symmetric(horizontal: 4),
                decoration: BoxDecoration(
                  color: isSelected ? Colors.white : Colors.white,
                  borderRadius: BorderRadius.circular(32),
                  border: Border.all(
                    color: isSelected ? Colors.blue : Colors.grey.shade300,
                    width: 1,
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      _getWeekdayAbbr(date),
                      style: TextStyle(
                        fontSize: 12,
                        color: isSelected ? Colors.blue : Colors.black38,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      "${date.day}",
                      style: TextStyle(
                        fontSize: 18,
                        color: isSelected ? Colors.blue : Colors.black87,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
        ),
      ),
    );
  }
}
