class Post {
  final String title;
  final String imageUrl;
  final String author;
  final String description;
  final List<Comment> comments;

  Post({
    required this.title,
    required this.imageUrl,
    required this.author,
    required this.description,
    this.comments = const [],
  });
}

class Comment {
  final String author;
  final String content;
  final DateTime timestamp;

  Comment({required this.author, required this.content, DateTime? timestamp})
    : timestamp = timestamp ?? DateTime.now();
}
