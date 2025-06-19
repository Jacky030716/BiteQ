import 'package:flutter/material.dart';

class CommentInputField extends StatelessWidget {
  final TextEditingController commentController;
  final VoidCallback onSubmitComment;

  const CommentInputField({
    super.key,
    required this.commentController,
    required this.onSubmitComment,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        border: const Border(top: BorderSide(color: Colors.grey, width: 0.4)),
      ),
      child: Row(
        children: [
          const Icon(Icons.chat_bubble_outline, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: TextField(
              controller: commentController,
              decoration: const InputDecoration.collapsed(
                hintText: "Write a comment...",
              ),
            ),
          ),
          TextButton(onPressed: onSubmitComment, child: const Text("Send")),
        ],
      ),
    );
  }
}
