import 'package:flutter/material.dart';
import 'post_controller.dart';
import 'post_detail_page.dart';

class ExplorePage extends StatelessWidget {
  final MyHomeController controller;

  const ExplorePage({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Explore'),
        actions: [
          IconButton(
            onPressed: () => Navigator.pushNamed(context, '/createPost'),
            icon: const Icon(Icons.add),
          ),
        ],
      ),
      body: GridView.builder(
        padding: const EdgeInsets.all(12),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: 1,
        ),
        itemCount: controller.posts.length,
        itemBuilder: (context, index) {
          final post = controller.posts[index];
          return GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => PostDetailPage(post: post)),
              );
            },
            child: Column(
              children: [
                Expanded(
                  child: Image.network(post.imageUrl, fit: BoxFit.cover),
                ),
                const SizedBox(height: 4),
                Text(
                  post.title,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                Text('by ${post.author}', style: const TextStyle(fontSize: 12)),
              ],
            ),
          );
        },
      ),
    );
  }
}
