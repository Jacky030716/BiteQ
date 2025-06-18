// features/posting/explore_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'post_model.dart';
import 'post_detail_page.dart';
import 'providers/post_providers.dart';

class ExplorePage extends ConsumerWidget {
  const ExplorePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final postController = ref.watch(postControllerProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Explore'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => context.push('/create-post'),
          ),
        ],
      ),
      body: GridView.builder(
        itemCount: postController.posts.length,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 0.9,
        ),
        itemBuilder: (context, index) {
          final post = postController.posts[index];
          return GestureDetector(
            onTap:
                () => context.push(
                  '/post-detail',
                  extra: {'post': post, 'postIndex': index},
                ),
            // ... rest of your widget
          );
        },
      ),
    );
  }
}
