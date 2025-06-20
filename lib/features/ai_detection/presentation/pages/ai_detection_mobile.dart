import 'dart:io';
import 'package:biteq/features/ai_detection/widgets/analyzing_section.dart';
import 'package:biteq/features/ai_detection/widgets/food_analysis_report.dart';
import 'package:biteq/features/ai_detection/widgets/food_analysis_report_card.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_gemini/flutter_gemini.dart';

class ImagePickerPage extends StatefulWidget {
  const ImagePickerPage({super.key});

  @override
  State<ImagePickerPage> createState() => _ImagePickerPageState();
}

class _ImagePickerPageState extends State<ImagePickerPage> {
  final picker = ImagePicker();
  String? _imagePath;
  bool _isAnalyzing = false;
  bool _isSaving = false;
  FoodAnalysisReport? _analysisReport;

  final Map<String, String> _foodDescriptions = {
    'chicken rice':
        'A popular Hainanese dish featuring poached chicken and seasoned rice.',
    'burger':
        'A sandwich consisting of a cooked patty of ground meat usually placed inside a sliced bun.',
    'pizza':
        'A savory dish of Italian origin consisting of a usually round, flattened base of leavened wheat-based dough topped with tomatoes, cheese, and various other ingredients.',
    'apple': 'A round fruit with crisp flesh and green or red skin.',
    'sandwich':
        'Two or more slices of bread or a split roll with a filling in between.',
    'salad':
        'A dish consisting of mixed pieces of food, sometimes with at least one raw ingredient, usually served with a dressing.',
    'soup':
        'A liquid food, generally served warm or hot, that is made by combining ingredients such as meat or vegetables with stock, juice, water, or another liquid.',
    'pasta':
        'A staple food of traditional Italian cuisine, made from unleavened dough of wheat flour mixed with water or eggs, and formed into sheets or various shapes, then cooked by boiling or baking.',
    'nasi lemak':
        'A fragrant rice dish cooked in coconut milk and pandan leaf, commonly found in Malaysia.',
  };

  double _parseNutrientValue(String? value) {
    if (value == null || value.isEmpty) return 0.0;
    return double.tryParse(value.trim()) ?? 0.0;
  }

  void _showSnackBar(String message, {bool isError = false}) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor:
              isError ? Colors.red.shade400 : Colors.green.shade600,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          duration: Duration(seconds: isError ? 4 : 2),
        ),
      );
    }
  }

  void _resetPage() {
    setState(() {
      _imagePath = null;
      _analysisReport = null;
      _isAnalyzing = false;
      _isSaving = false;
    });
  }

  void _cancelAnalysis() {
    _resetPage();
    _showSnackBar("Analysis canceled.");
  }

  Future<String?> _uploadImageToStorage(File imageFile) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return null;

      final now = DateTime.now();
      final dateStr =
          "${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}";
      final fileName =
          '${_analysisReport!.foodName.replaceAll(' ', '_')}_${now.millisecondsSinceEpoch}.jpg';

      final hour = now.hour;
      String mealType;
      if (hour < 11) {
        mealType = 'Breakfast';
      } else if (hour < 16) {
        mealType = 'Lunch';
      } else if (hour < 20) {
        mealType = 'Dinner';
      } else {
        mealType = 'Snack';
      }

      final storageRef = FirebaseStorage.instance
          .ref()
          .child('user_food_images')
          .child(user.uid)
          .child(dateStr)
          .child(mealType)
          .child(fileName);

      final uploadTask = await storageRef.putFile(imageFile);
      return await uploadTask.ref.getDownloadURL();
    } catch (e) {
      print('Error uploading image: $e');
      return null;
    }
  }

  Future<void> _pickImage(ImageSource source) async {
    setState(() {
      _isAnalyzing = true;
      _imagePath = null;
      _analysisReport = null;
    });

    try {
      final XFile? file = await picker.pickImage(
        source: source,
        maxWidth: 800,
        maxHeight: 800,
        imageQuality: 80,
      );

      if (file == null) {
        setState(() => _isAnalyzing = false);
        return;
      }

      setState(() => _imagePath = file.path);

      final imageBytes = await file.readAsBytes();

      const String nutritionPrompt =
          "Analyze this food image and provide its estimated nutritional information. "
          "Respond ONLY with a comma-separated list of numbers in this exact order: "
          "total_calories_kcal,protein_g,carbohydrates_g,fat_g. "
          "Do not include units, labels, or any other text. If a value cannot be determined, use 0. "
          "For example: 350,20,45,15";

      const String namePrompt =
          "Identify the primary food item in this image. "
          "Respond ONLY with the name of the food, nothing else. "
          "For example: 'Grilled Chicken Breast' or 'Caesar Salad'";

      const String descriptionPrompt =
          "Provide a brief description of the food item in this image. "
          "Respond ONLY with a short description within 20 words, nothing else. ";
      "For example: 'A grilled chicken breast served with steamed vegetables' or 'A fresh Caesar salad with croutons and parmesan cheese'";

      final nutritionResponseFuture = Gemini.instance.textAndImage(
        text: nutritionPrompt,
        images: [imageBytes],
      );
      final nameResponseFuture = Gemini.instance.textAndImage(
        text: namePrompt,
        images: [imageBytes],
      );

      final descriptionResponseFuture = Gemini.instance.textAndImage(
        text: descriptionPrompt,
        images: [imageBytes],
      );

      final List<dynamic> responses = await Future.wait([
        nutritionResponseFuture,
        nameResponseFuture,
        descriptionResponseFuture,
      ]);

      final nutritionResponse = responses[0];
      final nameResponse = responses[1];
      final descriptionResponse = responses[2];

      String? nutritionText;
      if (nutritionResponse?.content?.parts?.isNotEmpty == true) {
        final part = nutritionResponse!.content!.parts!.first;
        if (part is TextPart) {
          nutritionText = part.text;
        }
      }

      String? foodName;
      if (nameResponse?.content?.parts?.isNotEmpty == true) {
        final part = nameResponse!.content!.parts!.first;
        if (part is TextPart) {
          foodName = part.text.trim();
        }
      }

      String? descriptionText;
      if (descriptionResponse?.content?.parts?.isNotEmpty == true) {
        final part = descriptionResponse!.content!.parts!.first;
        if (part is TextPart) {
          descriptionText = part.text.trim();
        }
      }

      if (foodName != null &&
          nutritionText != null &&
          descriptionText != null &&
          nutritionText.isNotEmpty) {
        final cleanedNutritionText =
            nutritionText.replaceAll(RegExp(r'[^0-9,.]'), '').trim();
        final List<String> nutrientValues = cleanedNutritionText.split(',');

        if (nutrientValues.length >= 4) {
          final calories = _parseNutrientValue(nutrientValues[0]);
          final protein = _parseNutrientValue(nutrientValues[1]);
          final carbs = _parseNutrientValue(nutrientValues[2]);
          final fats = _parseNutrientValue(nutrientValues[3]);

          setState(() {
            _analysisReport = FoodAnalysisReport(
              foodName: foodName!,
              description: descriptionText ?? "No description available",
              calories: calories,
              carbs: carbs,
              protein: protein,
              fats: fats,
              timestamp: DateTime.now(),
            );
          });
          _showSnackBar("Food analysis complete!");
        } else {
          _showSnackBar(
            "Could not parse complete nutrient data. Please try again.",
            isError: true,
          );
        }
      } else {
        _showSnackBar(
          "Could not analyze the image. Please try again.",
          isError: true,
        );
      }
    } catch (e) {
      _showSnackBar("Error analyzing image: ${e.toString()}", isError: true);
    } finally {
      setState(() => _isAnalyzing = false);
    }
  }

  Future<void> _saveAnalysisResult() async {
    if (_analysisReport == null || _imagePath == null) {
      _showSnackBar('No analysis report to save.', isError: true);
      return;
    }

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      _showSnackBar('Please log in to save your meal.', isError: true);
      return;
    }

    setState(() => _isSaving = true);

    try {
      // Upload image first
      final imageUrl = await _uploadImageToStorage(File(_imagePath!));

      // Update analysis report with image URL
      final updatedReport = FoodAnalysisReport(
        foodName: _analysisReport!.foodName,
        description: _analysisReport!.description,
        calories: _analysisReport!.calories,
        carbs: _analysisReport!.carbs,
        protein: _analysisReport!.protein,
        fats: _analysisReport!.fats,
        timestamp: _analysisReport!.timestamp,
        imageUrl: imageUrl,
      );

      final firestore = FirebaseFirestore.instance;
      final now = DateTime.now();
      final dateStr =
          "${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}";
      final hour = now.hour;

      String mealType;
      String mealIcon;
      if (hour < 11) {
        mealType = 'Breakfast';
        mealIcon = 'assets/icons/breakfast.png';
      } else if (hour < 16) {
        mealType = 'Lunch';
        mealIcon = 'assets/icons/lunch.png';
      } else if (hour < 20) {
        mealType = 'Dinner';
        mealIcon = 'assets/icons/dinner.png';
      } else {
        mealType = 'Snack';
        mealIcon = 'assets/icons/snack.png';
      }

      // Structure matching your Firestore format
      final mealData = {
        'date': dateStr,
        'foods': [updatedReport.toFirestoreMap()],
        'id': mealType,
        'mealIcon': mealIcon,
        'name': mealType,
        'time': updatedReport.formatTime(now),
        'totalCals': '${updatedReport.calories.toInt()} Cals',
      };

      await firestore
          .collection('users')
          .doc(user.uid)
          .collection('meals_by_date')
          .doc((dateStr))
          .collection('mealTypes')
          .doc(mealType)
          .set(mealData, SetOptions(merge: true));

      _showSnackBar('Food analysis saved to $mealType!');
      _resetPage();
    } catch (e) {
      _showSnackBar('Failed to save: ${e.toString()}', isError: true);
    } finally {
      setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text(
          'AI Food Analysis',
          style: TextStyle(color: Colors.black87, fontWeight: FontWeight.w600),
        ),
        backgroundColor: Colors.white,
        centerTitle: true,
        elevation: 0,
        shadowColor: Colors.black.withOpacity(0.1),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Image display section
            if (_imagePath != null)
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      spreadRadius: 0,
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: Image.file(
                    File(_imagePath!),
                    width: double.infinity,
                    height: 300,
                    fit: BoxFit.cover,
                    errorBuilder:
                        (context, error, stackTrace) => Container(
                          height: 300,
                          color: Colors.grey[200],
                          child: Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.broken_image_outlined,
                                  size: 60,
                                  color: Colors.grey[600],
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  'Could not load image',
                                  style: TextStyle(
                                    color: Colors.grey[600],
                                    fontSize: 16,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                  ),
                ),
              ),

            SizedBox(height: _imagePath != null ? 24 : 0),

            if (_analysisReport == null && !_isAnalyzing)
              _buildImagePickerSection()
            else if (_isAnalyzing)
              AnalyzingSection()
            else if (_analysisReport != null)
              FoodAnalysisReportCard(
                report: _analysisReport!,
                onSave: _saveAnalysisResult,
                onCancel: _cancelAnalysis,
                isSaving: _isSaving,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildImagePickerSection() {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.1),
                spreadRadius: 0,
                blurRadius: 20,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            children: [
              Icon(
                Icons.camera_alt_outlined,
                size: 80,
                color: Colors.blue.shade300,
              ),
              const SizedBox(height: 16),
              Text(
                'Analyze Your Food',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[800],
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Take a photo or choose from gallery to get detailed nutritional information',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[600],
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 32),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => _pickImage(ImageSource.gallery),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue.shade600,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        elevation: 2,
                      ),
                      icon: const Icon(Icons.photo_library_outlined),
                      label: const Text(
                        'Gallery',
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => _pickImage(ImageSource.camera),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue.shade600,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        elevation: 2,
                      ),
                      icon: const Icon(Icons.camera_alt_outlined),
                      label: const Text(
                        'Camera',
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}
