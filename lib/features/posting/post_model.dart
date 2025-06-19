class Post {
  final String id;
  final String title;
  final String imageUrl;
  final String author;
  final String authorId;
  final String description;
  final DateTime createdAt;
  final List<String> likes;
  final List<Comment> comments;

  Post({
    required this.id,
    required this.title,
    required this.imageUrl,
    required this.author,
    required this.authorId,
    required this.description,
    DateTime? createdAt,
    List<String>? likes,
    List<Comment>? comments,
  }) : createdAt = createdAt ?? DateTime.now(),
       likes = likes ?? [],
       comments = comments ?? [];

  Post copyWith({
    String? id,
    String? title,
    String? imageUrl,
    String? author,
    String? authorId,
    String? description,
    DateTime? createdAt,
    List<String>? likes,
    List<Comment>? comments,
  }) {
    return Post(
      id: id ?? this.id,
      title: title ?? this.title,
      imageUrl: imageUrl ?? this.imageUrl,
      author: author ?? this.author,
      authorId: authorId ?? this.authorId,
      description: description ?? this.description,
      createdAt: createdAt ?? this.createdAt,
      likes: likes ?? this.likes,
      comments: comments ?? this.comments,
    );
  }
}

class Comment {
  final String id;
  final String authorId;
  final String authorName;
  final String content;
  final DateTime createdAt;
  final DateTime? editedAt;
  final List<Comment> replies;
  final List<String> likes;

  Comment({
    required this.id,
    required this.authorId,
    required this.authorName,
    required this.content,
    DateTime? createdAt,
    this.editedAt,
    List<Comment>? replies,
    List<String>? likes,
  }) : createdAt = createdAt ?? DateTime.now(),
       replies = replies ?? [],
       likes = likes ?? [];

  Comment copyWith({
    String? id,
    String? authorId,
    String? authorName,
    String? content,
    DateTime? createdAt,
    DateTime? editedAt,
    List<Comment>? replies,
    List<String>? likes,
  }) {
    return Comment(
      id: id ?? this.id,
      authorId: authorId ?? this.authorId,
      authorName: authorName ?? this.authorName,
      content: content ?? this.content,
      createdAt: createdAt ?? this.createdAt,
      editedAt: editedAt ?? this.editedAt,
      replies: replies ?? this.replies,
      likes: likes ?? this.likes,
    );
  }
}
