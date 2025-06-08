import 'dart:io';
import 'package:biteq/features/food_analysis/domain/entities/food_item.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class AddFoodDialog extends StatefulWidget {
  final String mealName;
  final Function(FoodItem) onAdd;

  const AddFoodDialog({super.key, required this.mealName, required this.onAdd});

  static Future<void> show(
    BuildContext context,
    String mealName,
    Function(FoodItem) onAdd,
  ) {
    return showDialog(
      context: context,
      builder: (context) => AddFoodDialog(mealName: mealName, onAdd: onAdd),
    );
  }

  @override
  State<AddFoodDialog> createState() => _AddFoodDialogState();
}

class _AddFoodDialogState extends State<AddFoodDialog> {
  final nameController = TextEditingController();
  final caloriesController = TextEditingController();
  final timeController = TextEditingController();
  final iconController = TextEditingController(text: "🍽️");
  String? selectedImagePath;

  @override
  void initState() {
    super.initState();
    // Set the default time to current time
    final now = DateTime.now();
    final hour =
        now.hour > 12
            ? now.hour - 12
            : now.hour == 0
            ? 12
            : now.hour;
    final minute = now.minute.toString().padLeft(2, '0');
    final period = now.hour >= 12 ? "PM" : "AM";
    timeController.text = "$hour:$minute $period";
  }

  @override
  void dispose() {
    nameController.dispose();
    caloriesController.dispose();
    timeController.dispose();
    iconController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 800,
      maxHeight: 800,
      imageQuality: 80,
    );

    if (image != null) {
      setState(() {
        selectedImagePath = image.path;
      });
    }
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hintText,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              color: Colors.black54,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 6),
          Container(
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(color: Colors.grey.shade300, width: 1.0),
              ),
            ),
            child: TextField(
              controller: controller,
              keyboardType: keyboardType,
              decoration: InputDecoration(
                hintText: hintText,
                hintStyle: TextStyle(color: Colors.grey.shade400),
                contentPadding: const EdgeInsets.symmetric(vertical: 8),
                border: InputBorder.none,
                isDense: true,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 0,
      backgroundColor: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.all(20),
        constraints: BoxConstraints(maxHeight: screenHeight * 0.6),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                "Add Food to ${widget.mealName}",
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              // Image Preview Area
              GestureDetector(
                onTap: _pickImage,
                child: Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child:
                      selectedImagePath != null
                          ? ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.file(
                              File(selectedImagePath!),
                              width: 100,
                              height: 100,
                              fit: BoxFit.cover,
                            ),
                          )
                          : Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.add_photo_alternate,
                                size: 36,
                                color: Colors.grey.shade500,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                "Add Image",
                                style: TextStyle(
                                  color: Colors.grey.shade600,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                ),
              ),
              const SizedBox(height: 16),
              _buildTextField(
                controller: nameController,
                label: "Food Name",
                hintText: "Enter food name",
              ),
              _buildTextField(
                controller: caloriesController,
                label: "Calories",
                hintText: "Enter calories",
                keyboardType: TextInputType.number,
              ),
              _buildTextField(
                controller: timeController,
                label: "Time Consumed",
                hintText: "HH:MM AM/PM",
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: () => Navigator.pop(context),
                      style: TextButton.styleFrom(
                        foregroundColor: const Color(0xFFAA6231),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: const Text(
                        "Cancel",
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        if (nameController.text.isNotEmpty &&
                            caloriesController.text.isNotEmpty) {
                          final foodItem = FoodItem(
                            name: nameController.text,
                            calories: "${caloriesController.text} calories",
                            image: selectedImagePath ?? iconController.text,
                            time: timeController.text,
                          );
                          widget.onAdd(foodItem);
                          Navigator.pop(context);
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFAA6231),
                        foregroundColor: Colors.white,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text("Add", style: TextStyle(fontSize: 16)),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
