// post_controller.dart
import 'post_model.dart';

class PostController {
  final List<Post> posts = [
    Post(
      title: 'Mediterranean Pasta',
      imageUrl:
          'https://cdn77-s3.lazycatkitchen.com/wp-content/uploads/2021/10/roasted-tomato-sauce-portion-800x1200.jpg',
      author: 'Dr. John',
      description: 'Healthy Mediterranean diet pasta with vegetables.',
    ),
  ];

  void addPost(Post post) {
    posts.add(post);
  }

  void addComment(int postIndex, Comment comment) {
    if (postIndex >= 0 && postIndex < posts.length) {
      posts[postIndex].comments.add(comment);
    }
  }
}
