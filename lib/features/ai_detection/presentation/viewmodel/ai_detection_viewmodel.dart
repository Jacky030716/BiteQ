import 'dart:io';
import 'dart:typed_data';
import 'package:image/image.dart' as img;

import 'package:flutter/services.dart';
import 'package:tflite_flutter/tflite_flutter.dart';

class AIDetectionViewModel {
  static final AIDetectionViewModel _instance =
      AIDetectionViewModel._internal();

  factory AIDetectionViewModel() => _instance;

  AIDetectionViewModel._internal();

  Interpreter? _interpreter;
  List<String>? _labels;
  bool _modelLoaded = false;

  bool get isModelLoaded => _modelLoaded;

  Future<void> loadModel() async {
    if (_modelLoaded) return;

    try {
      // Load the model
      _interpreter = await Interpreter.fromAsset(
        'assets/model/food_model.tflite',
      );

      // Load labels
      final labelsData = await rootBundle.loadString('assets/model/labels.txt');
      _labels =
          labelsData.split('\n').where((label) => label.isNotEmpty).toList();

      print('[DEBUG] Model loaded successfully');
      print('[DEBUG] Input shape: ${_interpreter!.getInputTensor(0).shape}');
      print('[DEBUG] Output shape: ${_interpreter!.getOutputTensor(0).shape}');
      print('[DEBUG] Labels count: ${_labels!.length}');

      _modelLoaded = true;
    } catch (e) {
      print('[ERROR] Failed to load model: $e');
    }
  }

  Future<List<dynamic>?> runModelOnImage(String imagePath) async {
    if (!_modelLoaded) {
      await loadModel();
    }

    if (_interpreter == null || _labels == null) {
      print('[ERROR] Model or labels not loaded');
      return null;
    }

    try {
      print('[DEBUG] Running model on image: $imagePath');

      // Read and decode image
      final imageBytes = await File(imagePath).readAsBytes();
      img.Image? image = img.decodeImage(imageBytes);

      if (image == null) {
        print('[ERROR] Failed to decode image');
        return null;
      }

      // Get input tensor shape
      final inputShape = _interpreter!.getInputTensor(0).shape;
      final inputHeight = inputShape[1];
      final inputWidth = inputShape[2];

      // Resize image to match model input size
      image = img.copyResize(image, width: inputWidth, height: inputHeight);

      // Convert image to input tensor
      final input = _imageToByteListFloat32(image, inputHeight, inputWidth);
      final inputTensor = input.reshape([1, inputHeight, inputWidth, 3]);

      // Prepare output tensor
      final outputShape = _interpreter!.getOutputTensor(0).shape;
      final output = List.filled(
        outputShape[1],
        0.0,
      ).reshape([1, outputShape[1]]);

      // Run inference
      _interpreter!.run(inputTensor, output);

      // Process results
      final results = <Map<String, dynamic>>[];
      final predictions = output[0] as List<double>;

      // Create list of predictions with indices
      final indexedPredictions = <Map<String, dynamic>>[];
      for (int i = 0; i < predictions.length && i < _labels!.length; i++) {
        indexedPredictions.add({
          'index': i,
          'confidence': predictions[i],
          'label': _labels![i],
        });
      }

      // Sort by confidence and take top results
      indexedPredictions.sort(
        (a, b) => b['confidence'].compareTo(a['confidence']),
      );

      // Filter by threshold and limit results
      const double threshold = 0.2;
      const int maxResults = 4;

      for (int i = 0; i < indexedPredictions.length && i < maxResults; i++) {
        final prediction = indexedPredictions[i];
        if (prediction['confidence'] >= threshold) {
          results.add({
            'label': prediction['label'],
            'confidence': prediction['confidence'],
            'index': prediction['index'],
          });
        }
      }

      print('[DEBUG] Processed ${results.length} results above threshold');
      return results;
    } catch (e) {
      print('[ERROR] Exception while running model: $e');
      return null;
    }
  }

  Float32List _imageToByteListFloat32(
    img.Image image,
    int inputHeight,
    int inputWidth,
  ) {
    final convertedBytes = Float32List(1 * inputHeight * inputWidth * 3);
    int pixelIndex = 0;

    for (int i = 0; i < inputHeight; i++) {
      for (int j = 0; j < inputWidth; j++) {
        final pixel = image.getPixel(j, i);

        // Extract RGB values correctly
        final r = pixel.r;
        final g = pixel.g;
        final b = pixel.b;

        // Normalize pixel values to [-1, 1] range (standard for many models)
        // Adjust normalization based on your model's requirements
        convertedBytes[pixelIndex++] = (r - 127.5) / 127.5;
        convertedBytes[pixelIndex++] = (g - 127.5) / 127.5;
        convertedBytes[pixelIndex++] = (b - 127.5) / 127.5;
      }
    }

    return convertedBytes;
  }

  void disposeModel() {
    print('[DEBUG] Disposing TFLite model.');
    _interpreter?.close();
    _interpreter = null;
    _labels = null;
    _modelLoaded = false;
  }
}
