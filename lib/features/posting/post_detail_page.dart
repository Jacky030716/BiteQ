import 'package:flutter/material.dart';
import 'post_model.dart';

class PostDetailPage extends StatelessWidget {
  final Post post;

  const PostDetailPage({super.key, required this.post});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(post.author),
        leading: const BackButton(),
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 12),
            child: Text("Follow", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Image.network(post.imageUrl, fit: BoxFit.cover),
            const SizedBox(height: 16),
            Text(
              post.title,
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(post.description, style: const TextStyle(fontSize: 14)),
            const SizedBox(height: 20),
            Row(
              children: const [
                Icon(Icons.chat_bubble_outline, size: 20),
                SizedBox(width: 6),
                Text("Say something"),
                Spacer(),
                Icon(Icons.favorite, color: Colors.red),
                SizedBox(width: 4),
                Text("626"),
                SizedBox(width: 12),
                Icon(Icons.comment),
                SizedBox(width: 4),
                Text("105"),
                SizedBox(width: 12),
                Icon(Icons.share),
                SizedBox(width: 4),
                Text("4"),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
