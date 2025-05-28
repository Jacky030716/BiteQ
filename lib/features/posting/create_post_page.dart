import 'package:flutter/material.dart';
import 'post_controller.dart';
import 'post_model.dart';

class CreatePostPage extends StatefulWidget {
  final MyHomeController controller;

  const CreatePostPage({super.key, required this.controller});

  @override
  State<CreatePostPage> createState() => _CreatePostPageState();
}

class _CreatePostPageState extends State<CreatePostPage> {
  final titleController = TextEditingController();
  final authorController = TextEditingController();
  final imageUrlController = TextEditingController();
  final descriptionController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Create Post')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: titleController,
              decoration: const InputDecoration(labelText: 'Title'),
            ),
            TextField(
              controller: authorController,
              decoration: const InputDecoration(labelText: 'Author'),
            ),
            TextField(
              controller: imageUrlController,
              decoration: const InputDecoration(labelText: 'Image URL'),
            ),
            TextField(
              controller: descriptionController,
              decoration: const InputDecoration(labelText: 'Description'),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                final post = Post(
                  title: titleController.text,
                  author: authorController.text,
                  imageUrl: imageUrlController.text,
                  description: descriptionController.text,
                );
                widget.controller.addPost(post);
                Navigator.pop(context);
              },
              child: const Text('Add Post'),
            ),
          ],
        ),
      ),
    );
  }
}
