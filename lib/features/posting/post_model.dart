class Post {
  final String? id;
  final String title;
  final String imageUrl;
  final String author;
  final String description;
  final int likes;

  Post({
    this.id,
    required this.title,
    required this.imageUrl,
    required this.author,
    required this.description,
    required this.likes,
  });

  factory Post.fromMap(Map<String, dynamic> data, String docId) {
    return Post(
      id: docId,
      title: data['title'] ?? '',
      imageUrl: data['imageUrl'] ?? '',
      author: data['author'] ?? '',
      description: data['description'] ?? '',
      likes: data['likes'] ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'imageUrl': imageUrl,
      'author': author,
      'description': description,
      'likes': likes,
    };
  }
}
