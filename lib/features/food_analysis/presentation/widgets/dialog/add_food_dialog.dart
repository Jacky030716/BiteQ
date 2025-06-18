import 'dart:io';
import 'package:biteq/features/food_analysis/domain/entities/food_item.dart';
import 'package:biteq/features/food_analysis/presentation/widgets/common/food_text_field.dart';
import 'package:biteq/features/food_analysis/presentation/widgets/common/time_selector.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gemini/flutter_gemini.dart';
import 'package:image_picker/image_picker.dart';

class AddFoodDialog extends StatefulWidget {
  final String mealName;
  final Function(FoodItem, File?) onAdd;

  const AddFoodDialog({super.key, required this.mealName, required this.onAdd});

  static Future<void> show(
    BuildContext context,
    String mealName,
    Function(FoodItem, File?) onAdd,
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
  final proteinController = TextEditingController();
  final carbsController = TextEditingController();
  final fatController = TextEditingController();

  String? selectedImagePath;
  bool _isProcessingImage = false;
  bool _isLoading = false;

  TimeOfDay selectedTime = TimeOfDay.now();

  @override
  void dispose() {
    nameController.dispose();
    caloriesController.dispose();
    proteinController.dispose();
    carbsController.dispose();
    fatController.dispose();
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
        _isProcessingImage = true;
      });
      await _analyzeImageWithGemini(File(image.path));
    }
  }

  Future<void> _analyzeImageWithGemini(File imageFile) async {
    try {
      final gemini = Gemini.instance;
      final imageBytes = await imageFile.readAsBytes();

      const String prompt =
          "Analyze this food image and provide nutritional information. "
          "Estimate the calories, protein (in grams), carbohydrates (in grams), and fat (in grams). "
          "Respond with ONLY numbers separated by commas in this exact format: calories,protein,carbs,fat "
          "For example: 250,15,30,10 "
          "If you cannot determine a value, use 0. Do not include any other text or explanations.";

      // ignore: deprecated_member_use
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
        // Extract food name in parallel for better user experience
        _extractFoodName(
          imageFile,
        ); // Call without awaiting to allow parallel execution

        // Clean the response to ensure it only contains numbers and commas
        // This regex removes anything that isn't a digit, comma, or period
        final cleanedText =
            responseText.replaceAll(RegExp(r'[^0-9,.]'), '').trim();

        // Handle potential multiple lines or extra spaces if the model deviates
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
    } finally {
      if (mounted) {
        setState(() {
          _isProcessingImage = false;
        });
      }
    }
  }

  /// Extract food name from image analysis
  Future<void> _extractFoodName(File imageFile) async {
    try {
      final gemini = Gemini.instance;
      final imageBytes = await imageFile.readAsBytes();

      const String namePrompt =
          "Look at this food image and identify what food it is. "
          "Respond with ONLY the name of the food, nothing else. "
          "For example: 'Grilled Chicken Breast' or 'Caesar Salad' or 'Chocolate Cake'";

      // ignore: deprecated_member_use
      final nameResponse = await gemini.textAndImage(
        text: namePrompt,
        images: [imageBytes],
      );

      String? foodName;
      if (nameResponse?.content?.parts?.isNotEmpty == true) {
        final part = nameResponse!.content!.parts!.first;
        if (part is TextPart) {
          foodName = part.text.trim();
        }
      }

      // Only update if the food name field is currently empty
      if (foodName != null &&
          foodName.isNotEmpty &&
          nameController.text.isEmpty) {
        if (mounted) {
          setState(() {
            nameController.text = foodName ?? '';
          });
        }
      }
    } catch (e) {
      print('Error extracting food name: $e');
    }
  }

  /// Parse and validate nutrient values
  String _parseNutrientValue(String value) {
    // Attempt to parse as double first for more flexibility, then convert to int
    final parsed = double.tryParse(value.trim()) ?? 0;
    return parsed.toStringAsFixed(0); // Return as string with no decimal places
  }

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
          duration: Duration(seconds: isError ? 4 : 2),
        ),
      );
    }
  }

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
        ), // Adjusted max height
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
              Stack(
                alignment: Alignment.center,
                children: [
                  GestureDetector(
                    onTap: _isProcessingImage ? null : _pickImage,
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
              FoodTextField(
                controller: nameController,
                label: "Food Name",
                hintText: "Enter food name",
                prefixIcon: Icons.restaurant_menu_outlined,
              ),
              FoodTextField(
                controller: caloriesController,
                label: "Calories",
                hintText: "Enter calories",
                keyboardType: TextInputType.number,
                prefixIcon: Icons.local_fire_department_rounded,
                suffixText: "kcal",
              ),
              FoodTextField(
                controller: proteinController,
                label: "Protein",
                hintText: "Enter protein in grams",
                keyboardType: TextInputType.number,
                prefixIcon: Icons.egg_alt,
                suffixText: "g",
              ),
              FoodTextField(
                controller: carbsController,
                label: "Carbs",
                hintText: "Enter carbs in grams",
                keyboardType: TextInputType.number,
                prefixIcon: Icons.bakery_dining,
                suffixText: "g",
              ),
              FoodTextField(
                controller: fatController,
                label: "Fat",
                hintText: "Enter fat in grams",
                keyboardType: TextInputType.number,
                prefixIcon: Icons.oil_barrel,
                suffixText: "g",
              ),
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
                      onPressed:
                          (_isLoading || _isProcessingImage)
                              ? null
                              : () async {
                                if (nameController.text.isEmpty ||
                                    caloriesController.text.isEmpty) {
                                  _showSnackBar(
                                    'Food Name and Calories are required.',
                                    isError: true,
                                  );
                                  return;
                                }

                                setState(() {
                                  _isLoading = true;
                                });
                                try {
                                  final foodItem = FoodItem(
                                    name: nameController.text,
                                    calories:
                                        "${caloriesController.text} calories",
                                    image: selectedImagePath ?? '',
                                    time: _formatTime(selectedTime),
                                    protein: int.tryParse(
                                      proteinController.text,
                                    ),
                                    carbs: int.tryParse(carbsController.text),
                                    fat: int.tryParse(fatController.text),
                                  );

                                  await widget.onAdd(
                                    foodItem,
                                    selectedImagePath != null
                                        ? File(selectedImagePath!)
                                        : null,
                                  );
                                  if (mounted) Navigator.pop(context);
                                } catch (e) {
                                  _showSnackBar(
                                    'Failed to add food: $e',
                                    isError: true,
                                  );
                                } finally {
                                  if (mounted) {
                                    setState(() {
                                      _isLoading = false;
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
                                "Add",
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
