// lib/features/ai_detection/presentation/viewmodel/ai_detection_viewmodel.dart
import 'package:tflite_v2/tflite_v2.dart';

class AIDetectionViewModel {
  static final AIDetectionViewModel _instance = AIDetectionViewModel._internal();

  factory AIDetectionViewModel() => _instance;

  AIDetectionViewModel._internal();

  bool _modelLoaded = false;

  bool get isModelLoaded => _modelLoaded;

  Future<void> loadModel() async {
    if (_modelLoaded) return;
    try {
      String? result = await Tflite.loadModel(
        model: 'assets/model/food_model.tflite',
        labels: 'assets/model/labels.txt',
      );
      print('[DEBUG] Model load result: $result');
      _modelLoaded = true;
    } catch (e) {
      print('[ERROR] Failed to load model: $e');
    }
  }

  Future<List<dynamic>?> runModelOnImage(String imagePath) async {
    if (!_modelLoaded) {
      await loadModel();
    }
    try {
      print('[DEBUG] Running model on image: $imagePath');
      return await Tflite.runModelOnImage(
        path: imagePath,
        numResults: 4,
        threshold: 0.2,
        imageMean: 127.5,
        imageStd: 127.5,
      );
    } catch (e) {
      print('[ERROR] Exception while running model: $e');
      return null;
    }
  }

  void disposeModel() {
    print('[DEBUG] Disposing TFLite model.');
    Tflite.close();
    _modelLoaded = false;
  }
}

