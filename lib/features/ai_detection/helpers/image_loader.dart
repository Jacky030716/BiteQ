export 'image_loader_stub.dart'
  if (dart.library.html) 'image_loader_web.dart'
  if (dart.library.io) 'image_loader_mobile.dart';
