class Post {
  final String? id; // ✅ Now optional
  final String title;
  final String imageUrl;
  final String author;
  final String description;
  final int likes;

  Post({
    this.id, // ✅ Default: null
    required this.title,
    required this.imageUrl,
    required this.author,
    required this.description,
    required this.likes,
  });

  factory Post.fromMap(Map<String, dynamic> data, String docId) {
    return Post(
      id: docId, // ✅ Assigned from Firestore
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
      // ⚠️ No need to include id here, it's stored in Firestore doc ID
    };
  }
}
