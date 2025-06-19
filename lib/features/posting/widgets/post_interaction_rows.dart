import 'package:flutter/material.dart';

class PostInteractionsRow extends StatelessWidget {
  final int likes;
  final bool isLiked;
  final VoidCallback onToggleLike;
  final VoidCallback onSharePost;
  final Future<String> Function() getLikeSummary;

  const PostInteractionsRow({
    super.key,
    required this.likes,
    required this.isLiked,
    required this.onToggleLike,
    required this.onSharePost,
    required this.getLikeSummary,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            IconButton(
              icon: Icon(
                Icons.favorite,
                color: isLiked ? Colors.red : Colors.grey,
              ),
              onPressed: onToggleLike,
            ),
            Text('$likes'),
            const SizedBox(width: 12),
            const Icon(Icons.comment_outlined, size: 22, color: Colors.grey),
            const SizedBox(width: 6),
            const Text("Comments"),
            const Spacer(),
            IconButton(icon: const Icon(Icons.share), onPressed: onSharePost),
          ],
        ),
        const SizedBox(height: 8),
        FutureBuilder<String>(
          future: getLikeSummary(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Text(
                'Loading likes...',
                style: TextStyle(color: Colors.grey),
              );
            }
            if (snapshot.hasError) {
              return const Text(
                'Error loading likes.',
                style: TextStyle(color: Colors.red),
              );
            }
            if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return const Text(
                'No likes yet.',
                style: TextStyle(color: Colors.grey),
              );
            }
            return Text(
              snapshot.data!,
              style: const TextStyle(color: Colors.grey),
            );
          },
        ),
      ],
    );
  }
}
