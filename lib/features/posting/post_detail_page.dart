import 'package:biteq/features/posting/widgets/comment_input_field.dart';
import 'package:biteq/features/posting/widgets/post_comment_section.dart';
import 'package:biteq/features/posting/widgets/post_content_display.dart';
import 'package:biteq/features/posting/widgets/post_interaction_rows.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:biteq/features/auth/presentation/providers/auth_state_provider.dart';
import 'post_model.dart';

class PostCurrentUser {
  final String? id;
  final String name;

  PostCurrentUser({required this.id, required this.name});
}

final postCurrentUserProvider = FutureProvider<PostCurrentUser>((ref) async {
  final authState = await ref.watch(authStateProvider.future);

  if (authState != null) {
    final userName = authState.name.isNotEmpty ? authState.name : 'User';
    return PostCurrentUser(id: authState.id, name: userName);
  } else {
    return PostCurrentUser(id: null, name: 'Guest User');
  }
});

class PostDetailPage extends ConsumerStatefulWidget {
  final Post post;

  const PostDetailPage({super.key, required this.post});

  @override
  ConsumerState<PostDetailPage> createState() => _PostDetailPageState();
}

class _PostDetailPageState extends ConsumerState<PostDetailPage> {
  late int _likes;
  bool _isLiked = false; // Initialize _isLiked to false directly

  final TextEditingController _commentController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _likes = widget.post.likes;
    _checkLikeStatus();
  }

  Future<void> _checkLikeStatus() async {
    final currentUserData = ref.read(postCurrentUserProvider).value;
    final userId = currentUserData?.id;

    if (userId != null &&
        widget.post.id != null &&
        widget.post.id!.isNotEmpty) {
      try {
        final likeDoc =
            await FirebaseFirestore.instance
                .collection('posts')
                .doc(widget.post.id)
                .collection('likes')
                .doc(userId)
                .get();

        if (mounted) {
          setState(() {
            _isLiked = likeDoc.exists;
          });
        }
      } catch (e) {
        if (mounted) {
          setState(() {
            _isLiked = false; // Default to false on error
          });
        }
      }
    } else {
      if (mounted) {
        setState(() {
          _isLiked = false; // Cannot be liked if no user ID
        });
      }
    }
  }

  void _toggleLike() async {
    final currentUserData = ref.read(postCurrentUserProvider).value;
    final userId = currentUserData?.id;
    final userName = currentUserData?.name;

    if (userId == null ||
        userName == null ||
        widget.post.id == null ||
        widget.post.id!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please log in to like this post."),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    final postRef = FirebaseFirestore.instance
        .collection('posts')
        .doc(widget.post.id);
    final likeRef = postRef.collection('likes').doc(userId);

    try {
      if (_isLiked) {
        await likeRef.delete();
        await postRef.update({'likes': FieldValue.increment(-1)});
        setState(() {
          _likes--;
          _isLiked = false;
        });
      } else {
        await likeRef.set({
          'userId': userId,
          'userName': userName,
        }); // Use userName from provider
        await postRef.update({'likes': FieldValue.increment(1)});
        setState(() {
          _likes++;
          _isLiked = true;
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Failed to like post: $e"),
          backgroundColor: Colors.red.shade400,
        ),
      );
    }
  }

  void _sharePost() async {
    if (widget.post.imageUrl.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("No image URL to copy.")));
      return;
    }
    await Clipboard.setData(ClipboardData(text: widget.post.imageUrl));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Image URL copied to clipboard")),
    );
  }

  void _submitComment() async {
    final text = _commentController.text.trim();
    if (text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Comment cannot be empty."),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    final currentUserData = ref.read(postCurrentUserProvider).value;
    final userId = currentUserData?.id;
    final userName = currentUserData?.name;

    if (userId == null ||
        userName == null ||
        widget.post.id == null ||
        widget.post.id!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please log in to comment."),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    try {
      await FirebaseFirestore.instance
          .collection('posts')
          .doc(widget.post.id)
          .collection('comments')
          .add({
            'text': text,
            'userId': userId,
            'userName': userName, // Use userName from provider
            'timestamp': FieldValue.serverTimestamp(),
          });

      _commentController.clear();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Comment added!"),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Failed to submit comment: $e"),
          backgroundColor: Colors.red.shade400,
        ),
      );
    }
  }

  Stream<QuerySnapshot> _commentStream() {
    if (widget.post.id == null || widget.post.id!.isEmpty) {
      return const Stream<QuerySnapshot>.empty();
    }
    return FirebaseFirestore.instance
        .collection('posts')
        .doc(widget.post.id)
        .collection('comments')
        .orderBy('timestamp', descending: true)
        .snapshots();
  }

  Future<String> _getLikeSummary() async {
    if (widget.post.id == null || widget.post.id!.isEmpty) {
      return 'No likes yet.';
    }
    final snapshot =
        await FirebaseFirestore.instance
            .collection('posts')
            .doc(widget.post.id)
            .collection('likes')
            .get();

    final names =
        snapshot.docs.map((doc) => doc['userName'] ?? 'User').toList();

    if (names.isEmpty) return 'No likes yet.';
    if (names.length == 1) return '${names[0]} liked this';
    if (names.length == 2) return '${names[0]} and ${names[1]} liked this';
    return '${names[0]}, ${names[1]} and ${names.length - 2} others liked this'; // More precise
  }

  @override
  Widget build(BuildContext context) {
    final currentUserAsyncValue = ref.watch(postCurrentUserProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.post.author),
        backgroundColor: Colors.blue.shade300,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Center(
              child: Text(
                "Follow",
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                PostContentDisplay(
                  imageUrl: widget.post.imageUrl,
                  title: widget.post.title,
                  description: widget.post.description,
                ),
                const SizedBox(height: 24),

                PostInteractionsRow(
                  likes: _likes,
                  isLiked: _isLiked,
                  onToggleLike: _toggleLike,
                  onSharePost: _sharePost,
                  getLikeSummary: _getLikeSummary,
                ),
                const SizedBox(height: 24),

                PostCommentSection(commentStream: _commentStream()),
              ],
            ),
          ),
          CommentInputField(
            commentController: _commentController,
            onSubmitComment: _submitComment,
          ),
        ],
      ),
    );
  }
}
