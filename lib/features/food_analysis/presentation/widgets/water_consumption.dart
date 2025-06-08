import 'package:flutter/material.dart';

class WaterConsumption extends StatefulWidget {
  const WaterConsumption({super.key});

  @override
  State<WaterConsumption> createState() => _WaterConsumptionState();
}

class _WaterConsumptionState extends State<WaterConsumption> {
  // Track number of cups consumed
  int cupsConsumed = 3;
  // Track edit mode state
  bool isEditMode = false;
  // Track time for each cup (in a real app, you'd store these with the cups)
  final List<String> cupTimes = ["8:21 AM", "10:45 AM", "12:30 PM"];

  // Add a new cup of water
  void _addCup() {
    setState(() {
      cupsConsumed++;
      // Get current time for new cup
      final now = DateTime.now();
      final hour = now.hour > 12 ? now.hour - 12 : now.hour;
      final period = now.hour >= 12 ? "PM" : "AM";
      final minute = now.minute.toString().padLeft(2, '0');
      cupTimes.add("$hour:$minute $period");
    });
  }

  // Remove a cup of water
  void _removeCup(int index) {
    setState(() {
      if (cupsConsumed > 0 && index < cupTimes.length) {
        cupsConsumed--;
        cupTimes.removeAt(index);
      }
    });
  }

  // Toggle edit mode
  void _toggleEditMode() {
    setState(() {
      isEditMode = !isEditMode;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.grey.shade300, width: 1),
        borderRadius: BorderRadius.all(Radius.circular(16)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Daily goal indicator
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Icons.water_drop, color: Colors.blue, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    "$cupsConsumed/8 cups",
                    style: const TextStyle(
                      color: Colors.blue,
                      fontWeight: FontWeight.w500,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
              TextButton.icon(
                onPressed: _toggleEditMode,
                icon: Icon(
                  isEditMode ? Icons.check : Icons.edit,
                  color: Colors.lightBlue,
                  size: 14,
                ),
                label: Text(
                  isEditMode ? "Done" : "Edit",
                  style: const TextStyle(color: Colors.lightBlue, fontSize: 14),
                ),
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  backgroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 10),

          // Progress bar
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              borderRadius: BorderRadius.circular(10),
              value: cupsConsumed / 8,
              backgroundColor: Colors.grey.shade100,
              valueColor: const AlwaysStoppedAnimation<Color>(
                Colors.blueAccent,
              ),
              minHeight: 10,
            ),
          ),

          const SizedBox(height: 24),

          // Water cups row
          SizedBox(
            height: 100,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: cupsConsumed + 1, // +1 for the "add" button
              itemBuilder: (context, index) {
                // If this is the last item, show the add button
                if (index == cupsConsumed) {
                  return GestureDetector(
                    onTap: _addCup,
                    child: Container(
                      width: 60,
                      margin: const EdgeInsets.only(right: 16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(15),
                        border: Border.all(color: Colors.white54, width: 2),
                      ),
                      child: const Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.add_circle_outline,
                            color: Colors.lightBlue,
                            size: 28,
                          ),
                          SizedBox(height: 8),
                          Text(
                            "Add Cup",
                            style: TextStyle(
                              color: Colors.lightBlue,
                              fontSize: 10,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                // Show cups that have been consumed
                return Stack(
                  children: [
                    Container(
                      width: 60,
                      margin: const EdgeInsets.only(right: 16),
                      decoration: BoxDecoration(
                        color: const Color.fromARGB(255, 236, 246, 255),
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.water_drop,
                            color: Colors.blue,
                            size: 28,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            cupTimes[index],
                            style: TextStyle(
                              color: Colors.blue.shade800,
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Show remove button in edit mode
                    if (isEditMode)
                      Positioned(
                        top: 2,
                        right: 10,
                        child: GestureDetector(
                          onTap: () => _removeCup(index),
                          child: Container(
                            padding: const EdgeInsets.all(2),
                            decoration: const BoxDecoration(
                              color: Colors.red,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.close,
                              color: Colors.white,
                              size: 16,
                            ),
                          ),
                        ),
                      ),
                  ],
                );
              },
            ),
          ),

          const SizedBox(height: 16),

          // Latest consumption
          if (cupsConsumed > 0)
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color.fromARGB(255, 236, 246, 255),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(Icons.water_drop, color: Colors.blue.shade700),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Last Cup",
                        style: TextStyle(
                          color: Colors.blueAccent,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        cupsConsumed > 0 ? cupTimes.last : "",
                        style: TextStyle(color: Colors.lightBlue, fontSize: 13),
                      ),
                    ],
                  ),
                  const Spacer(),
                  Text(
                    "250ml",
                    style: TextStyle(
                      color: Colors.lightBlue,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
