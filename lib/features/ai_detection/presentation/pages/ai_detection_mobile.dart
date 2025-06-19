import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:biteq/features/ai_detection/presentation/viewmodel/ai_detection_viewmodel.dart';
import 'package:biteq/features/ai_detection/helpers/image_loader.dart';

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
      setState(() => _isModelLoading = false);
    }
  }

  Future<void> _pickImage(ImageSource source) async {
    if (_isModelLoading || !viewModel.isModelLoaded) return;

    final XFile? file = await picker.pickImage(source: source);
    if (file == null) return;

    final path = await loadImage(file.path);
    setState(() => _imagePath = path);

    final result = await viewModel.runModelOnImage(path);
    setState(() => _results = result);

    if (result != null && result.isNotEmpty) {
      await _saveDetectionResultToMeal(result);
    }
  }

  Future<void> _saveDetectionResultToMeal(List<dynamic> results) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    try {
      final firestore = FirebaseFirestore.instance;
      final now = DateTime.now();
      final dateStr = "${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}";
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

      final mealDocRef = firestore
          .collection('users')
          .doc(user.uid)
          .collection('meals_by_date')
          .doc(dateStr)
          .collection('mealTypes')
          .doc(mealType);

      final docSnapshot = await mealDocRef.get();
      final detectionResults = results
          .map((result) => {
                'label': result['label'],
                'confidence': result['confidence'],
                'timestamp': Timestamp.now(),
              })
          .toList();

      if (docSnapshot.exists) {
        await mealDocRef.update({
          'detection_results': FieldValue.arrayUnion(detectionResults),
          'last_updated': Timestamp.now(),
        });
      } else {
        await mealDocRef.set({
          'detection_results': detectionResults,
          'created_at': Timestamp.now(),
          'last_updated': Timestamp.now(),
          'meal_type': mealType,
          'date': dateStr,
        });
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Food detected and saved to $mealType!'),
            backgroundColor: Colors.blue.shade400,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Failed to save detection results'),
            backgroundColor: Colors.red.shade400,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
      }
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
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        ..._results!.map(
          (r) => Card(
            elevation: 3,
            color: Colors.blue.shade50,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: ListTile(
              leading: const Icon(Icons.fastfood_outlined, color: Colors.blue),
              title: Text(r['label'], style: const TextStyle(fontWeight: FontWeight.w600)),
              trailing: Text(
                '${(r['confidence'] * 100).toStringAsFixed(1)}%',
                style: TextStyle(color: Colors.blue.shade900, fontWeight: FontWeight.w500),
              ),
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Text(
          'AI Food Detection',
          style: TextStyle(color: Colors.black87, fontWeight: FontWeight.w600),
        ),
        backgroundColor: Colors.white,
        centerTitle: true,
        elevation: 0.5,
        shadowColor: Colors.black.withOpacity(0.05),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            if (_imagePath != null)
              Card(
                elevation: 3,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                clipBehavior: Clip.antiAlias,
                child: Image.file(
                  File(_imagePath!),
                  width: double.infinity,
                  height: 280,
                  fit: BoxFit.cover,
                ),
              ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _isModelLoading ? null : () => _pickImage(ImageSource.gallery),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue.shade600,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    icon: const Icon(Icons.photo_library_outlined),
                    label: const Text('Gallery'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _isModelLoading ? null : () => _pickImage(ImageSource.camera),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue.shade600,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    icon: const Icon(Icons.camera_alt_outlined),
                    label: const Text('Camera'),
                  ),
                ),
              ],
            ),
            if (_isModelLoading)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(width: 12),
                    Text("Loading model..."),
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
