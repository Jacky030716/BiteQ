import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:biteq/features/auth/presentation/providers/auth_state_provider.dart'; // adjust as needed
import 'post_model.dart';

class PostDetailPage extends ConsumerStatefulWidget {
  final Post post;

  const PostDetailPage({super.key, required this.post});

  @override
  ConsumerState<PostDetailPage> createState() => _PostDetailPageState();
}

class _PostDetailPageState extends ConsumerState<PostDetailPage> {
  late int _likes;
  late bool _isLiked;
  final TextEditingController _commentController = TextEditingController();

  late String _userId;
  late String _userName;

  @override
  void initState() {
    super.initState();
    
    _likes = widget.post.likes;
    _isLiked = false;
    _userId = '';
    _userName = '';
    _initUserData();
  }

  Future<void> _initUserData() async {
    final user = ref.read(authStateProvider).value;
    if (user == null) return;

    _userId = user.id;
    _userName = user.name;

    final likeDoc = await FirebaseFirestore.instance
        .collection('posts')
        .doc(widget.post.id)
        .collection('likes')
        .doc(_userId)
        .get();

    if (mounted) {
      setState(() {
        _isLiked = likeDoc.exists;
      });
    }
  }

void _toggleLike() async {
  if (!mounted || _userId.isEmpty || widget.post.id?.isEmpty != false) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("User not ready or post ID missing."),
        backgroundColor: Colors.red,
      ),
    );
    return;
  }

  final postRef = FirebaseFirestore.instance.collection('posts').doc(widget.post.id);
  final likeRef = postRef.collection('likes').doc(_userId);

  try {
    if (_isLiked) {
      await likeRef.delete();
      await postRef.update({'likes': FieldValue.increment(-1)});
      setState(() {
        _likes--;
        _isLiked = false;
      });
    } else {
      await likeRef.set({'userId': _userId, 'userName': _userName});
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
    await Clipboard.setData(ClipboardData(text: widget.post.imageUrl));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Image URL copied to clipboard")),
    );
  }

  void _submitComment() async {
    final text = _commentController.text.trim();
    if (text.isEmpty || widget.post.id == null) return;

    await FirebaseFirestore.instance
        .collection('posts')
        .doc(widget.post.id)
        .collection('comments')
        .add({
      'text': text,
      'userId': _userId,
      'userName': _userName,
      'timestamp': FieldValue.serverTimestamp(),
    });

    _commentController.clear();
  }

  Stream<QuerySnapshot> _commentStream() {
    return FirebaseFirestore.instance
        .collection('posts')
        .doc(widget.post.id)
        .collection('comments')
        .orderBy('timestamp', descending: true)
        .snapshots();
  }

  Future<String> _getLikeSummary() async {
    final snapshot = await FirebaseFirestore.instance
        .collection('posts')
        .doc(widget.post.id)
        .collection('likes')
        .get();

    final names = snapshot.docs.map((doc) => doc['userName'] ?? 'User').toList();

    if (names.isEmpty) return 'No likes yet.';
    if (names.length == 1) return '${names[0]} liked this';
    if (names.length == 2) return '${names[0]} and ${names[1]} liked this';
    return '${names[0]}, ${names[1]} and others liked this';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.post.author),
        backgroundColor: Colors.blue.shade300,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Center(
              child: Text("Follow", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
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
                ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Image.network(
                    widget.post.imageUrl,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  widget.post.title,
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.blue.shade900),
                ),
                const SizedBox(height: 12),
                Text(widget.post.description, style: const TextStyle(fontSize: 16, height: 1.5)),
                const SizedBox(height: 24),
                Row(
                  children: [
                    IconButton(
                      icon: Icon(
                        Icons.favorite,
                        color: _isLiked ? Colors.red : Colors.grey,
                      ),
                      onPressed: _toggleLike,
                    ),
                    Text('$_likes'),
                    const SizedBox(width: 12),
                    const Icon(Icons.comment_outlined, size: 22, color: Colors.grey),
                    const SizedBox(width: 6),
                    const Text("Comments"),
                    const Spacer(),
                    IconButton(
                      icon: const Icon(Icons.share),
                      onPressed: _sharePost,
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                FutureBuilder<String>(
                  future: _getLikeSummary(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) return const SizedBox();
                    return Text(snapshot.data!, style: const TextStyle(color: Colors.grey));
                  },
                ),
                const SizedBox(height: 24),
                const Text("Comments", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                StreamBuilder<QuerySnapshot>(
                  stream: _commentStream(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    final comments = snapshot.data!.docs;

                    if (comments.isEmpty) {
                      return const Padding(
                        padding: EdgeInsets.symmetric(vertical: 20),
                        child: Text("No comments yet."),
                      );
                    }

                    return ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: comments.length,
                      separatorBuilder: (_, __) => const Divider(),
                      itemBuilder: (context, index) {
                        final comment = comments[index].data() as Map<String, dynamic>;
                        return ListTile(
                          leading: const Icon(Icons.person_outline),
                          title: Text(comment['userName'] ?? 'User'),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(comment['text'] ?? ''),
                              Text(
                                (comment['timestamp'] as Timestamp?)?.toDate().toString().substring(0, 16) ?? '',
                                style: const TextStyle(fontSize: 12, color: Colors.grey),
                              ),
                            ],
                          ),
                        );
                      },
                    );
                  },
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              border: const Border(
                top: BorderSide(color: Colors.grey, width: 0.4),
              ),
            ),
            child: Row(
              children: [
                const Icon(Icons.chat_bubble_outline, size: 20),
                const SizedBox(width: 10),
                Expanded(
                  child: TextField(
                    controller: _commentController,
                    decoration: const InputDecoration.collapsed(hintText: "Write a comment..."),
                  ),
                ),
                TextButton(
                  onPressed: _submitComment,
                  child: const Text("Send"),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
