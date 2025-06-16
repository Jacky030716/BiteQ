import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart'; // For date formatting

final selectedDateProvider = StateProvider<DateTime>((ref) {
  return DateTime.now();
});

class AnalyzeDateSelection extends ConsumerWidget {
  const AnalyzeDateSelection({super.key});

  // Helper to get abbreviated weekday name
  String _getWeekdayAbbr(DateTime date) {
    return DateFormat('EEE').format(date); // e.g., 'Mon', 'Tue'
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedDate = ref.watch(selectedDateProvider);

    return Container(
      width: double.infinity,
      height: 80,
      margin: const EdgeInsets.symmetric(vertical: 16),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: List.generate(7, (index) {
            final today = DateTime.now();
            // Generate dates for the last 7 days, including today
            final date = DateTime(
              today.year,
              today.month,
              today.day,
            ).subtract(Duration(days: 6 - index));

            // Determine if this date is currently selected
            final isSelected =
                selectedDate.year == date.year &&
                selectedDate.month == date.month &&
                selectedDate.day == date.day;

            return GestureDetector(
              onTap: () {
                // Update the selectedDateProvider when a date is tapped
                ref.read(selectedDateProvider.notifier).state = date;
              },
              child: Container(
                width: 50,
                margin: const EdgeInsets.symmetric(horizontal: 4),
                decoration: BoxDecoration(
                  color:
                      isSelected
                          ? Colors.blue.shade50
                          : Colors.white, // Lighter blue when selected
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
