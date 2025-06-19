import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'post_model.dart';
import 'post_controller.dart';
import 'package:biteq/features/posting/providers/post_providers.dart';

class PostDetailPage extends ConsumerStatefulWidget {
  final String postId;

  const PostDetailPage({super.key, required this.postId});

  @override
  ConsumerState<PostDetailPage> createState() => _PostDetailPageState();
}

class _PostDetailPageState extends ConsumerState<PostDetailPage> {
  final TextEditingController _commentController = TextEditingController();
  final TextEditingController _replyController = TextEditingController();
  String? _replyingToCommentId;
  String? _editingCommentId;
  String? _editingCommentContent;

  @override
  void dispose() {
    _commentController.dispose();
    _replyController.dispose();
    super.dispose();
  }

  void _submitComment() {
    if (_commentController.text.trim().isEmpty) return;

    final newComment = Comment(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      authorId: 'currentUserId', // Replace with actual user ID
      authorName: 'Current User', // Replace with actual user name
      content: _commentController.text.trim(),
    );

    ref
        .read(postControllerProvider.notifier)
        .addComment(widget.postId, newComment);
    _commentController.clear();
  }

  void _submitReply(String commentId) {
    if (_replyController.text.trim().isEmpty) return;

    final newReply = Comment(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      authorId: 'currentUserId', // Replace with actual user ID
      authorName: 'Current User', // Replace with actual user name
      content: _replyController.text.trim(),
    );

    ref
        .read(postControllerProvider.notifier)
        .addReply(widget.postId, commentId, newReply);
    _replyController.clear();
    _replyingToCommentId = null;
  }

  void _toggleLike() {
    ref
        .read(postControllerProvider.notifier)
        .toggleLike(widget.postId, 'currentUserId');
  }

  void _toggleCommentLike(String commentId) {
    ref
        .read(postControllerProvider.notifier)
        .toggleCommentLike(widget.postId, commentId, 'currentUserId');
  }

  void _deleteComment(String commentId) {
    ref
        .read(postControllerProvider.notifier)
        .deleteComment(widget.postId, commentId);
  }

  void _startEditingComment(String commentId, String content) {
    setState(() {
      _editingCommentId = commentId;
      _editingCommentContent = content;
    });
  }

  void _updateComment(String commentId) {
    if (_editingCommentContent == null || _editingCommentContent!.isEmpty)
      return;

    ref
        .read(postControllerProvider.notifier)
        .updateComment(widget.postId, commentId, _editingCommentContent!);

    setState(() {
      _editingCommentId = null;
      _editingCommentContent = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final post = ref
        .watch(postControllerProvider.notifier)
        .getPostById(widget.postId);
    final isLiked = post.likes.contains('currentUserId');

    return Scaffold(
      appBar: AppBar(
        title: Text(post.author),
        leading: const BackButton(),
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 12),
            child: Text("Follow", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.network(
                      post.imageUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => const Icon(Icons.error),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    post.title,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(post.description, style: const TextStyle(fontSize: 14)),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      IconButton(
                        icon: Icon(
                          isLiked ? Icons.favorite : Icons.favorite_border,
                          color: isLiked ? Colors.red : null,
                        ),
                        onPressed: _toggleLike,
                      ),
                      Text(post.likes.length.toString()),
                      const SizedBox(width: 20),
                      const Icon(Icons.comment),
                      const SizedBox(width: 4),
                      Text(post.comments.length.toString()),
                      const Spacer(),
                      const Icon(Icons.share),
                    ],
                  ),
                  const Divider(),
                  const Text(
                    'Comments',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                  const SizedBox(height: 10),
                  ...post.comments
                      .map((comment) => _buildComment(comment))
                      .toList(),
                ],
              ),
            ),
          ),
          _buildCommentInput(),
        ],
      ),
    );
  }

  Widget _buildComment(Comment comment) {
    final isEditing = _editingCommentId == comment.id;
    final isReplying = _replyingToCommentId == comment.id;
    final isLiked = comment.likes.contains('currentUserId');
    final isCurrentUser = comment.authorId == 'currentUserId';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ListTile(
          contentPadding: EdgeInsets.zero,
          leading: CircleAvatar(child: Text(comment.authorName[0])),
          title: Text(comment.authorName),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (comment.editedAt != null)
                Text(
                  'Edited',
                  style: TextStyle(color: Colors.grey, fontSize: 10),
                ),
              if (isEditing)
                Column(
                  children: [
                    TextFormField(
                      initialValue: _editingCommentContent,
                      onChanged: (value) => _editingCommentContent = value,
                    ),
                    Row(
                      children: [
                        TextButton(
                          onPressed:
                              () => setState(() => _editingCommentId = null),
                          child: const Text('Cancel'),
                        ),
                        TextButton(
                          onPressed: () => _updateComment(comment.id),
                          child: const Text('Save'),
                        ),
                      ],
                    ),
                  ],
                )
              else
                Text(comment.content),
            ],
          ),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: Icon(
                  isLiked ? Icons.favorite : Icons.favorite_border,
                  size: 16,
                  color: isLiked ? Colors.red : null,
                ),
                onPressed: () => _toggleCommentLike(comment.id),
              ),
              Text(comment.likes.length.toString()),
              if (isCurrentUser) ...[
                IconButton(
                  icon: const Icon(Icons.edit, size: 16),
                  onPressed:
                      () => _startEditingComment(comment.id, comment.content),
                ),
                IconButton(
                  icon: const Icon(Icons.delete, size: 16),
                  onPressed: () => _deleteComment(comment.id),
                ),
              ],
              IconButton(
                icon: const Icon(Icons.reply, size: 16),
                onPressed: () {
                  setState(() {
                    _replyingToCommentId = isReplying ? null : comment.id;
                    _editingCommentId = null;
                  });
                },
              ),
            ],
          ),
        ),
        if (isReplying)
          Padding(
            padding: const EdgeInsets.only(left: 50, bottom: 10),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _replyController,
                    decoration: InputDecoration(
                      hintText: 'Write a reply...',
                      suffixIcon: IconButton(
                        icon: const Icon(Icons.send),
                        onPressed: () => _submitReply(comment.id),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        Padding(
          padding: const EdgeInsets.only(left: 50),
          child: Column(
            children:
                comment.replies.map((reply) => _buildComment(reply)).toList(),
          ),
        ),
        const Divider(),
      ],
    );
  }

  Widget _buildCommentInput() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        children: [
          const CircleAvatar(child: Icon(Icons.person)),
          const SizedBox(width: 10),
          Expanded(
            child: TextField(
              controller: _commentController,
              decoration: InputDecoration(
                hintText: 'Add a comment...',
                suffixIcon: IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: _submitComment,
                ),
              ),
              onSubmitted: (_) => _submitComment(),
            ),
          ),
        ],
      ),
    );
  }
}
