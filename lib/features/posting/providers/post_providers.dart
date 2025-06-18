// features/posting/providers/post_providers.dart
import 'package:biteq/features/posting/post_controller.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final postControllerProvider = Provider<PostController>((ref) {
  return PostController();
});
