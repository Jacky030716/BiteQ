import 'dart:io';
import 'package:biteq/features/food_analysis/domain/entities/food_item.dart';
import 'package:biteq/features/food_analysis/presentation/widgets/common/food_text_field.dart'; // Reused
import 'package:biteq/features/food_analysis/presentation/widgets/common/time_selector.dart'; // Reused
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_gemini/flutter_gemini.dart'; // New: For Gemini Vision integration

class EditFoodDialog extends StatefulWidget {
  final FoodItem foodItem;
  final Function(FoodItem) onSave;

  const EditFoodDialog({
    super.key,
    required this.foodItem,
    required this.onSave,
  });

  static Future<void> show(
    BuildContext context,
    FoodItem foodItem,
    Function(FoodItem) onSave,
  ) {
    return showDialog(
      context: context,
      builder: (context) => EditFoodDialog(foodItem: foodItem, onSave: onSave),
    );
  }

  @override
  State<EditFoodDialog> createState() => _EditFoodDialogState();
}

class _EditFoodDialogState extends State<EditFoodDialog> {
  // Text controllers for food details
  late final TextEditingController nameController;
  late final TextEditingController caloriesController;
  late final TextEditingController proteinController; // New: For protein
  late final TextEditingController carbsController; // New: For carbohydrates
  late final TextEditingController fatController; // New: For fat

  // State variables for image and loading feedback
  String? selectedImagePath;
  bool _isProcessingImage = false; // New: To show loading for image analysis
  bool _isLoading = false; // New: To show loading for save operation

  // Time selector state
  late TimeOfDay selectedTime; // Changed from TextEditingController

  @override
  void initState() {
    super.initState();
    nameController = TextEditingController(text: widget.foodItem.name);
    // Extract numerical calories from "X calories" string
    caloriesController = TextEditingController(
      text: widget.foodItem.calories.split(' ')[0],
    );

    // Initialize new nutritional controllers from existing FoodItem, default to 0 if null
    proteinController = TextEditingController(
      text: (widget.foodItem.protein ?? 0).toStringAsFixed(0),
    );
    carbsController = TextEditingController(
      text: (widget.foodItem.carbs ?? 0).toStringAsFixed(0),
    );
    fatController = TextEditingController(
      text: (widget.foodItem.fat ?? 0).toStringAsFixed(0),
    );

    // Parse existing time string to TimeOfDay for TimeSelector
    selectedTime = _parseTime(widget.foodItem.time);

    // Set initial selected image path if it exists and is a file path
    selectedImagePath =
        widget.foodItem.image.contains('http')
            ? widget.foodItem.image
            : widget.foodItem.image.isNotEmpty
            ? widget.foodItem.image
            : null;
  }

  @override
  void dispose() {
    nameController.dispose();
    caloriesController.dispose();
    proteinController.dispose(); // Dispose new controllers
    carbsController.dispose(); // Dispose new controllers
    fatController.dispose(); // Dispose new controllers
    super.dispose();
  }

  /// Parses a time string (e.g., "HH:MM AM/PM") into a TimeOfDay object.
  TimeOfDay _parseTime(String timeString) {
    try {
      final parts = timeString.split(' ');
      if (parts.length != 2) return TimeOfDay.now(); // Invalid format
      final timeParts = parts[0].split(':');
      if (timeParts.length != 2) return TimeOfDay.now(); // Invalid format

      int hour = int.parse(timeParts[0]);
      final minute = int.parse(timeParts[1]);
      final period = parts[1].toUpperCase();

      if (period == 'PM' && hour != 12) {
        hour += 12;
      } else if (period == 'AM' && hour == 12) {
        hour = 0; // Midnight
      }
      return TimeOfDay(hour: hour, minute: minute);
    } catch (e) {
      print("Error parsing time string: $e");
      return TimeOfDay.now();
    }
  }

  /// Handles picking an image from the gallery.
  /// After picking, it triggers Gemini analysis for nutritional data.
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
        _isProcessingImage = true; // Start loading for image analysis
      });
      await _analyzeImageWithGemini(File(image.path));
    }
  }

  /// Analyzes a food image using the Gemini Pro Vision model.
  /// This function sends an image file and a text prompt to the Gemini API
  /// to get nutritional information, then parses the response to update
  /// the UI text fields.
  Future<void> _analyzeImageWithGemini(File imageFile) async {
    try {
      final gemini = Gemini.instance;
      final imageBytes = await imageFile.readAsBytes();

      const String prompt =
          "Analyze this food image and provide nutritional information. "
          "Estimate the calories, protein (in grams), carbohydrates (in grams), and fat (in grams). "
          "Respond with ONLY numbers separated by commas in this exact format: calories,protein,carbs,fat. "
          "For example: 250,15,30,10. "
          "If you cannot determine a value, use 0. Do not include any other text or explanations.";

      final response = await gemini.textAndImage(
        text: prompt,
        images: [imageBytes],
      );

      String? responseText;
      if (response?.content?.parts?.isNotEmpty == true) {
        final part = response!.content!.parts!.first;
        if (part is TextPart) {
          responseText = part.text;
        }
      }

      if (responseText != null && responseText.isNotEmpty) {
        print('Gemini Response Text: $responseText');

        // Extract food name from a more detailed analysis (optional, runs concurrently or after)
        await _extractFoodName(imageFile);

        // Clean the response to ensure it only contains numbers and commas
        final cleanedText =
            responseText.replaceAll(RegExp(r'[^0-9.,\s]'), '').trim();

        // Handle multiple lines or spaces
        final numbersOnly = cleanedText.replaceAll(RegExp(r'\s+'), '');
        final List<String> nutrientValues = numbersOnly.split(',');

        if (nutrientValues.length >= 4) {
          setState(() {
            caloriesController.text = _parseNutrientValue(nutrientValues[0]);
            proteinController.text = _parseNutrientValue(nutrientValues[1]);
            carbsController.text = _parseNutrientValue(nutrientValues[2]);
            fatController.text = _parseNutrientValue(nutrientValues[3]);
          });

          _showSnackBar("Nutritional information extracted successfully!");
        } else {
          _showSnackBar(
            "Could not parse complete nutrient data. Please verify the values.",
            isError: true,
          );
        }
      } else {
        _showSnackBar(
          "Could not analyze the image. Please try again or enter values manually.",
          isError: true,
        );
      }
    } catch (e) {
      _showSnackBar("Error analyzing image: ${e.toString()}", isError: true);
      print('Error analyzing image with Gemini: $e');
    } finally {
      setState(() {
        _isProcessingImage = false; // End loading for image analysis
      });
    }
  }

  /// Attempts to extract the food name from the image using Gemini.
  Future<void> _extractFoodName(File imageFile) async {
    try {
      final gemini = Gemini.instance;
      final imageBytes = await imageFile.readAsBytes();

      const String namePrompt =
          "Look at this food image and identify what food it is. "
          "Respond with ONLY the name of the food, nothing else. "
          "For example: 'Grilled Chicken Breast' or 'Caesar Salad' or 'Chocolate Cake'";

      final nameResponse = await gemini.textAndImage(
        text: namePrompt,
        images: [imageBytes],
      );

      String? foodName;
      if (nameResponse?.content?.parts?.isNotEmpty == true) {
        final part = nameResponse!.content!.parts!.first;
        if (part is TextPart) {
          foodName = part.text?.trim();
        }
      }

      // Only update if the food name field is empty
      if (foodName != null &&
          foodName.isNotEmpty &&
          nameController.text.isEmpty) {
        setState(() {
          nameController.text = foodName ?? '';
        });
      }
    } catch (e) {
      print('Error extracting food name: $e');
      // Don't show a snackbar for this, as it's an optional enhancement
    }
  }

  /// Parses a string value into a double and formats it to a fixed decimal.
  String _parseNutrientValue(String value) {
    final parsed = double.tryParse(value.trim()) ?? 0;
    return parsed.toStringAsFixed(0);
  }

  /// Displays a SnackBar message to the user.
  void _showSnackBar(String message, {bool isError = false}) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor:
              isError ? Colors.red.shade400 : Colors.green.shade400,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          duration: Duration(seconds: isError ? 4 : 2), // Longer for errors
        ),
      );
    }
  }

  /// Formats a TimeOfDay object into a "HH:MM AM/PM" string.
  String _formatTime(TimeOfDay time) {
    final hour = time.hourOfPeriod == 0 ? 12 : time.hourOfPeriod;
    final minute = time.minute.toString().padLeft(2, '0');
    final period = time.period == DayPeriod.am ? 'AM' : 'PM';
    return '$hour:$minute $period';
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
        constraints: BoxConstraints(
          maxHeight: screenHeight * 0.8,
        ), // Increased max height
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                "Edit ${widget.foodItem.name}",
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              // Image Preview Area with loading indicator
              Stack(
                alignment: Alignment.center,
                children: [
                  GestureDetector(
                    onTap:
                        _isProcessingImage
                            ? null
                            : _pickImage, // Disable tap during processing
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
                                // **FIXED:** Dynamically choose Image.file or Image.network
                                child:
                                    selectedImagePath!.startsWith('http')
                                        ? Image.network(
                                          selectedImagePath!,
                                          width: 100,
                                          height: 100,
                                          fit: BoxFit.cover,
                                          errorBuilder:
                                              (context, error, stackTrace) =>
                                              // Fallback to a broken image icon or placeholder
                                              const Icon(
                                                Icons.broken_image,
                                                size: 50,
                                                color: Colors.grey,
                                              ),
                                        )
                                        : Image.file(
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
                  if (_isProcessingImage)
                    Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        color: Colors.black54,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Center(
                        child: CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Colors.white,
                          ),
                          strokeWidth: 3,
                        ),
                      ),
                    ),
                ],
              ),
              if (_isProcessingImage)
                const Padding(
                  padding: EdgeInsets.only(top: 8.0),
                  child: Text(
                    "Analyzing image...",
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ),
              const SizedBox(height: 16),
              // Food Name Text Field
              FoodTextField(
                controller: nameController,
                label: "Food Name",
                hintText: "Enter food name",
                prefixIcon: Icons.restaurant_menu_outlined,
              ),
              // Calories Text Field
              FoodTextField(
                controller: caloriesController,
                label: "Calories",
                hintText: "Enter calories",
                keyboardType: TextInputType.number,
                prefixIcon: Icons.local_fire_department_rounded,
                suffixText: "kcal",
              ),
              // Protein Text Field (New)
              FoodTextField(
                controller: proteinController,
                label: "Protein",
                hintText: "Enter protein in grams",
                keyboardType: TextInputType.number,
                prefixIcon: Icons.egg_alt,
                suffixText: "g",
              ),
              // Carbs Text Field (New)
              FoodTextField(
                controller: carbsController,
                label: "Carbs",
                hintText: "Enter carbs in grams",
                keyboardType: TextInputType.number,
                prefixIcon: Icons.bakery_dining,
                suffixText: "g",
              ),
              // Fat Text Field (New)
              FoodTextField(
                controller: fatController,
                label: "Fat",
                hintText: "Enter fat in grams",
                keyboardType: TextInputType.number,
                prefixIcon: Icons.oil_barrel,
                suffixText: "g",
              ),
              // Time Selector (Replaced TextField)
              TimeSelector(
                selectedTime: selectedTime,
                onTimeSelected: (TimeOfDay newTime) {
                  setState(() {
                    selectedTime = newTime;
                  });
                },
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: () => Navigator.pop(context),
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.blueAccent,
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
                      // Disable button if loading or processing image
                      onPressed:
                          (_isLoading || _isProcessingImage)
                              ? null
                              : () async {
                                // Basic validation
                                if (nameController.text.isEmpty ||
                                    caloriesController.text.isEmpty) {
                                  _showSnackBar(
                                    'Food Name and Calories are required.',
                                    isError: true,
                                  );
                                  return;
                                }

                                setState(() {
                                  _isLoading = true; // Start loading for save
                                });

                                try {
                                  // Create updated FoodItem
                                  final foodItem = FoodItem(
                                    name: nameController.text,
                                    // Reconstruct calories string
                                    calories:
                                        "${caloriesController.text} calories",
                                    image:
                                        selectedImagePath ??
                                        '', // Use selectedImagePath
                                    time: _formatTime(
                                      selectedTime,
                                    ), // Use formatted time
                                    protein: int.tryParse(
                                      proteinController.text,
                                    ),
                                    carbs: int.tryParse(carbsController.text),
                                    fat: int.tryParse(fatController.text),
                                  );

                                  await widget.onSave(foodItem);
                                  if (mounted) Navigator.pop(context);
                                  _showSnackBar(
                                    "Food item updated successfully!",
                                  );
                                } catch (e) {
                                  _showSnackBar(
                                    'Failed to update food: $e',
                                    isError: true,
                                  );
                                  print(
                                    'Error saving food item: $e',
                                  ); // Log detailed error
                                } finally {
                                  if (mounted) {
                                    setState(() {
                                      _isLoading =
                                          false; // End loading for save
                                    });
                                  }
                                }
                              },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blueAccent,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child:
                          (_isLoading || _isProcessingImage)
                              ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    Colors.white,
                                  ),
                                  strokeWidth: 2,
                                ),
                              )
                              : const Text(
                                "Save",
                                style: TextStyle(fontSize: 16),
                              ),
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
