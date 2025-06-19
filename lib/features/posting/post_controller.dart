import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'post_model.dart';

class PostController extends StateNotifier<List<Post>> {
  final Ref ref;

  PostController(this.ref) : super([]) {
    // Initialize with sample data
    state = [
      Post(
        id: '1',
        title: 'Mediterranean Pasta',
        imageUrl:
            'https://cdn77-s3.lazycatkitchen.com/wp-content/uploads/2021/10/roasted-tomato-sauce-portion-800x1200.jpg',
        author: 'Dr. John',
        authorId: 'user1',
        description: 'Healthy Mediterranean diet pasta with vegetables.',
        likes: ['user1', 'user2'],
        comments: [
          Comment(
            id: 'c1',
            authorId: 'user2',
            authorName: 'Jane Doe',
            content: 'This looks delicious!',
            likes: ['user1'],
            replies: [
              Comment(
                id: 'c1r1',
                authorId: 'user1',
                authorName: 'Dr. John',
                content: 'Thanks! It tastes even better than it looks!',
              ),
            ],
          ),
        ],
      ),
    ];
  }

  Post getPostById(String id) {
    try {
      return state.firstWhere((post) => post.id == id);
    } catch (e) {
      throw Exception('Post not found');
    }
  }

  void addPost(Post post) {
    state = [...state, post];
  }

  void toggleLike(String postId, String userId) {
    state = [
      for (final post in state)
        if (post.id == postId)
          post.copyWith(
            likes:
                post.likes.contains(userId)
                    ? post.likes.where((id) => id != userId).toList()
                    : [...post.likes, userId],
          )
        else
          post,
    ];
  }

  void addComment(String postId, Comment comment) {
    state = [
      for (final post in state)
        if (post.id == postId)
          post.copyWith(comments: [...post.comments, comment])
        else
          post,
    ];
  }

  void addReply(String postId, String commentId, Comment reply) {
    state = [
      for (final post in state)
        if (post.id == postId)
          post.copyWith(
            comments: [
              for (final comment in post.comments)
                if (comment.id == commentId)
                  comment.copyWith(replies: [...comment.replies, reply])
                else
                  comment,
            ],
          )
        else
          post,
    ];
  }

  void deleteComment(String postId, String commentId) {
    state = [
      for (final post in state)
        if (post.id == postId)
          post.copyWith(
            comments: post.comments.where((c) => c.id != commentId).toList(),
          )
        else
          post,
    ];
  }

  void updateComment(String postId, String commentId, String newContent) {
    state = [
      for (final post in state)
        if (post.id == postId)
          post.copyWith(
            comments: [
              for (final comment in post.comments)
                if (comment.id == commentId)
                  comment.copyWith(
                    content: newContent,
                    editedAt: DateTime.now(),
                  )
                else
                  comment,
            ],
          )
        else
          post,
    ];
  }

  void toggleCommentLike(String postId, String commentId, String userId) {
    state = [
      for (final post in state)
        if (post.id == postId)
          post.copyWith(
            comments: [
              for (final comment in post.comments)
                if (comment.id == commentId)
                  comment.copyWith(
                    likes:
                        comment.likes.contains(userId)
                            ? comment.likes.where((id) => id != userId).toList()
                            : [...comment.likes, userId],
                  )
                else
                  comment,
            ],
          )
        else
          post,
    ];
  }
}
