import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:biteq/features/home_dashboard/presentation/pages/home_screen.dart'; // Import to access providers

void showTimePeriodBottomSheet(BuildContext context, WidgetRef ref) {
  final currentValue = ref.read(selectedTimePeriodProvider);

  showModalBottomSheet(
    context: context,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    backgroundColor: Colors.transparent,
    builder: (context) {
      return StatefulBuilder(
        builder: (context, setState) {
          String selectedValue = currentValue;

          return Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            ),
            padding: const EdgeInsets.all(16),
            child: Theme(
              data: Theme.of(context).copyWith(
                unselectedWidgetColor: Colors.white, // For the radio buttons
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children:
                    ['Day', 'Week', 'Month'].map((period) {
                      return RadioListTile<String>(
                        title: Text(
                          period,
                          style: const TextStyle(color: Colors.black),
                        ),
                        value: period,
                        groupValue: selectedValue,
                        activeColor: Colors.blue,
                        onChanged: (value) {
                          if (value != null) {
                            setState(() => selectedValue = value);
                            ref
                                .read(selectedTimePeriodProvider.notifier)
                                .state = value;
                            // Invalidate relevant providers to force a refresh with the new time period
                            ref.invalidate(chartDataProvider);
                            ref.invalidate(dynamicNutritionProvider);
                            Navigator.pop(context);
                          }
                        },
                      );
                    }).toList(),
              ),
            ),
          );
        },
      );
    },
  );
}
