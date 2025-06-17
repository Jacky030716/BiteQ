import 'package:flutter_gemini/flutter_gemini.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class GeminiService {
  static final GeminiService _instance = GeminiService._internal();

  factory GeminiService() {
    return _instance;
  }

  GeminiService._internal();

  void initialize() {
    Gemini.init(apiKey: dotenv.env['GEMINI_API_KEY']!);
  }
}
