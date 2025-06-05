// ignore_for_file: deprecated_member_use
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:biteq/features/ai_detection/helpers/image_loader.dart';

class ImagePickerPage extends StatefulWidget {
  const ImagePickerPage({super.key});
  @override
  State<ImagePickerPage> createState() => _ImagePickerPageState();
}

class _ImagePickerPageState extends State<ImagePickerPage> {
  final picker = ImagePicker();

  String? _imageUrl;

  Future<void> _pickImage() async {
    final XFile? file = await picker.pickImage(source: ImageSource.gallery);
    if (file == null) return;
    final Uint8List bytes = await file.readAsBytes();
    final url = await loadImage(bytes);
    setState(() => _imageUrl = url);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Food Detection")),
      body: Column(
        children: [
          if (_imageUrl != null)
            Image.network(_imageUrl!, width: 300, height: 300),
          ElevatedButton(
            onPressed: _pickImage,
            child: const Text("Pick Image"),
          ),
        ],
      ),
    );
  }
}
