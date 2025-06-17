import 'post_model.dart';

class MyHomeController {
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
}
