import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:biteq/features/posting/post_controller.dart';
import 'package:biteq/features/posting/post_model.dart';

final postControllerProvider =
    StateNotifierProvider<PostController, List<Post>>((ref) {
      return PostController(ref);
    });
