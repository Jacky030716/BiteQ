import 'dart:io';
import 'package:biteq/features/ai_detection/presentation/viewmodel/ai_detection_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:biteq/features/ai_detection/helpers/image_loader.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ImagePickerPage extends StatefulWidget {
  const ImagePickerPage({super.key});

  @override
  State<ImagePickerPage> createState() => _ImagePickerPageState();
}

class _ImagePickerPageState extends State<ImagePickerPage> {
  final picker = ImagePicker();
  late final AIDetectionViewModel viewModel;
  String? _imagePath;
  List<dynamic>? _results;
  bool _isModelLoading = true;

  @override
  void initState() {
    super.initState();
    viewModel = AIDetectionViewModel();
    _initModel();
  }

  Future<void> _initModel() async {
    await viewModel.loadModel();
    if (mounted) {
      setState(() {
        _isModelLoading = false;
      });
    }
  }

  Future<void> _pickImage(ImageSource source) async {
    if (_isModelLoading || !viewModel.isModelLoaded) {
      print('[ERROR] Model is not ready yet');
      return;
    }

    final XFile? file = await picker.pickImage(source: source);
    if (file == null) return;

    final path = await loadImage(file.path);
    setState(() {
      _imagePath = path;
    });

    final result = await viewModel.runModelOnImage(path);

    setState(() {
      _results = result;
    });

    // Save to Firestore with proper structure
    if (result != null && result.isNotEmpty) {
      await _saveDetectionResultToMeal(result);
    }
  }

  Widget _buildResults() {
    if (_results == null || _results!.isEmpty) {
      return const Text('No detection results yet');
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Detection Results:',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        const SizedBox(height: 8),
        ..._results!.map(
          (r) => Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: ListTile(
              title: Text(r['label']),
              trailing: Text('${(r['confidence'] * 100).toStringAsFixed(1)}%'),
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _saveDetectionResultToMeal(List<dynamic> results) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return;
    }

    try {
      final firestore = FirebaseFirestore.instance;
      final now = DateTime.now();
      final dateStr =
          "${now.year.toString().padLeft(4, '0')}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}";

      // Determine meal type based on current time
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

      // Create the document path: users/{userID}/meals_by_date/{date}/mealTypes/{type}
      final mealDocRef = firestore
          .collection('users')
          .doc(user.uid)
          .collection('meals_by_date')
          .doc(dateStr)
          .collection('mealTypes')
          .doc(mealType);

      // Get existing document or create new one
      final docSnapshot = await mealDocRef.get();

      // Prepare detection results data
      final detectionResults =
          results
              .map(
                (result) => {
                  'label': result['label'],
                  'confidence': result['confidence'],
                  'timestamp': Timestamp.now(),
                },
              )
              .toList();

      if (docSnapshot.exists) {
        // Update existing document by adding to detection_results array
        await mealDocRef.update({
          'detection_results': FieldValue.arrayUnion(detectionResults),
          'last_updated': Timestamp.now(),
        });
      } else {
        // Create new document with detection results
        await mealDocRef.set({
          'detection_results': detectionResults,
          'created_at': Timestamp.now(),
          'last_updated': Timestamp.now(),
          'meal_type': mealType,
          'date': dateStr,
        });
      }

      // Show success message to user
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Food detected and saved to $mealType!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to save detection results'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    // Note: Don't dispose model here if it's a singleton being used elsewhere
    // viewModel.disposeModel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Food Detection")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (_imagePath != null)
              Image.file(File(_imagePath!), width: 350, height: 350),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton.icon(
                  onPressed:
                      _isModelLoading
                          ? null
                          : () => _pickImage(ImageSource.gallery),
                  icon: const Icon(Icons.photo_library),
                  label: const Text('Gallery'),
                ),
                ElevatedButton.icon(
                  onPressed:
                      _isModelLoading
                          ? null
                          : () => _pickImage(ImageSource.camera),
                  icon: const Icon(Icons.camera_alt),
                  label: const Text('Camera'),
                ),
              ],
            ),
            if (_isModelLoading)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(width: 16),
                    Text('Loading AI model...'),
                  ],
                ),
              ),
            const SizedBox(height: 24),
            _buildResults(),
          ],
        ),
      ),
    );
  }
}
