import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:biteq/features/ai_detection/helpers/image_loader.dart';
import 'package:biteq/features/ai_detection/presentation/viewmodel/ai_detection_viewmodel.dart';

class ImagePickerPage extends StatefulWidget {
  const ImagePickerPage({Key? key}) : super(key: key);

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
    print('[DEBUG] Result from model: $result');

    setState(() {
      _results = result;
    });
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
        ..._results!.map((r) => Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: ListTile(
                title: Text(r['label']),
                trailing: Text('${(r['confidence'] * 100).toStringAsFixed(1)}%'),
              ),
            )),
      ],
    );
  }

  @override
  void dispose() {
    if (viewModel.isModelLoaded) {
      // viewModel.disposeModel();  // ❌ REMOVE THIS
    }
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
                  onPressed: () => _pickImage(ImageSource.gallery),
                  icon: const Icon(Icons.photo_library),
                  label: const Text('Gallery'),
                ),
                ElevatedButton.icon(
                  onPressed: () => _pickImage(ImageSource.camera),
                  icon: const Icon(Icons.camera_alt),
                  label: const Text('Camera'),
                ),
              ],
            ),
            const SizedBox(height: 24),
            _buildResults(),
          ],
        ),
      ),
    );
  }
}
