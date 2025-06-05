export 'ai_detection_stub.dart'
  if (dart.library.html) 'ai_detection_web.dart'
  if (dart.library.io) 'ai_detection_mobile.dart';
