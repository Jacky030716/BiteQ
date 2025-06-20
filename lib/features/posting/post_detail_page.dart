import 'package:biteq/features/posting/widgets/comment_input_field.dart';
import 'package:biteq/features/posting/widgets/post_comment_section.dart';
import 'package:biteq/features/posting/widgets/post_content_display.dart';
import 'package:biteq/features/posting/widgets/post_interaction_rows.dart';
import 'package:flutter/material.dart';
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

class _PostDetailPageState extends ConsumerState<PostDetailPage>
    with TickerProviderStateMixin {
  late int _likes;
  bool _isLiked = false;
  final TextEditingController _commentController = TextEditingController();
  late AnimationController _likeAnimationController;
  late AnimationController _fadeAnimationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _likes = widget.post.likes;
    _checkLikeStatus();
    
    // Initialize animations
    _likeAnimationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _fadeAnimationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.2,
    ).animate(CurvedAnimation(
      parent: _likeAnimationController,
      curve: Curves.elasticOut,
    ));
    
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeAnimationController,
      curve: Curves.easeInOut,
    ));
    
    _fadeAnimationController.forward();
  }

  @override
  void dispose() {
    _likeAnimationController.dispose();
    _fadeAnimationController.dispose();
    super.dispose();
  }

  Future<void> _checkLikeStatus() async {
    final currentUserData = ref.read(postCurrentUserProvider).value;
    final userId = currentUserData?.id;

    if (userId != null && widget.post.id != null && widget.post.id!.isNotEmpty) {
      try {
        final likeDoc = await FirebaseFirestore.instance
            .collection('posts')
            .doc(widget.post.id)
            .collection('likes')
            .doc(userId)
            .get();

        if (mounted) {
          setState(() => _isLiked = likeDoc.exists);
        }
      } catch (_) {
        if (mounted) setState(() => _isLiked = false);
      }
    }
  }

  void _toggleLike() async {
    final currentUserData = ref.read(postCurrentUserProvider).value;
    final userId = currentUserData?.id;
    final userName = currentUserData?.name;

    if (userId == null || userName == null || widget.post.id == null) {
      _showSnackBar("Please log in to like this post.", Colors.orange);
      return;
    }

    // Animate like button
    _likeAnimationController.forward().then((_) {
      _likeAnimationController.reverse();
    });

    final postRef = FirebaseFirestore.instance.collection('posts').doc(widget.post.id);
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
        await likeRef.set({'userId': userId, 'userName': userName});
        await postRef.update({'likes': FieldValue.increment(1)});
        setState(() {
          _likes++;
          _isLiked = true;
        });
      }
    } catch (e) {
      _showSnackBar("Failed to like post: $e", Colors.red.shade400);
    }
  }

  Future<String> _getLikeSummary() async {
    if (widget.post.id == null) return 'No likes yet.';
    final snapshot = await FirebaseFirestore.instance
        .collection('posts')
        .doc(widget.post.id)
        .collection('likes')
        .get();

    final names = snapshot.docs.map((doc) => doc['userName'] ?? 'User').toList();
    if (names.isEmpty) return 'No likes yet.';
    if (names.length == 1) return '${names[0]} liked this';
    if (names.length == 2) return '${names[0]} and ${names[1]} liked this';
    return '${names[0]}, ${names[1]} and ${names.length - 2} others liked this';
  }

  void _submitComment() async {
    final text = _commentController.text.trim();
    if (text.isEmpty) {
      _showSnackBar("Comment cannot be empty.", Colors.orange);
      return;
    }

    final currentUserData = ref.read(postCurrentUserProvider).value;
    final userId = currentUserData?.id;
    final userName = currentUserData?.name;

    if (userId == null || userName == null || widget.post.id == null) {
      _showSnackBar("Please log in to comment.", Colors.orange);
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
        'userName': userName,
        'timestamp': FieldValue.serverTimestamp(),
      });

      _commentController.clear();
      _showSnackBar("Comment added!", Colors.green);
    } catch (e) {
      _showSnackBar("Failed to submit comment: $e", Colors.red.shade400);
    }
  }

  void _showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  Stream<QuerySnapshot> _commentStream() {
    if (widget.post.id == null) {
      return const Stream<QuerySnapshot>.empty();
    }
    return FirebaseFirestore.instance
        .collection('posts')
        .doc(widget.post.id)
        .collection('comments')
        .orderBy('timestamp', descending: true)
        .snapshots();
  }

  Widget _buildNutritionCard() {
    final hasNutrition = widget.post.calories != null ||
        widget.post.carbs != null ||
        widget.post.protein != null ||
        widget.post.fats != null;

    if (!hasNutrition) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.green.shade50, Colors.green.shade100],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.green.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.green.shade400,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.restaurant_menu,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  'Nutrition Facts',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.green.shade700,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                _buildNutritionItem(
                  'Calories',
                  widget.post.calories?.toString() ?? '-',
                  Icons.local_fire_department,
                  Colors.orange,
                ),
                _buildNutritionItem(
                  'Carbs',
                  widget.post.carbs?.toString() ?? '-',
                  Icons.grain,
                  Colors.amber,
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                _buildNutritionItem(
                  'Protein',
                  widget.post.protein?.toString() ?? '-',
                  Icons.fitness_center,
                  Colors.red,
                ),
                _buildNutritionItem(
                  'Fats',
                  widget.post.fats?.toString() ?? '-',
                  Icons.opacity,
                  Colors.purple,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNutritionItem(String label, String value, IconData icon, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        margin: const EdgeInsets.only(right: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.2)),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIngredientsCard() {
    if (widget.post.ingredients == null) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.blue.shade50, Colors.blue.shade100],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade400,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.list_alt,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  'Ingredients',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue.shade700,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              widget.post.ingredients!,
              style: const TextStyle(
                height: 1.6,
                fontSize: 14,
                color: Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTargetUsersCard() {
    if (widget.post.targetUsers == null || widget.post.targetUsers!.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.purple.shade50, Colors.purple.shade100],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.purple.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.purple.shade400,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.people,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  'Target Audience',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.purple.shade700,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8.0,
              runSpacing: 8.0,
              children: widget.post.targetUsers!.map((tag) {
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.purple.shade300, Colors.purple.shade400],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.purple.withOpacity(0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Text(
                    tag,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 300,
            floating: false,
            pinned: true,
            backgroundColor: Colors.white,
            elevation: 0,
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  // Background image
                  if (widget.post.imageUrl != null)
                    Image.network(
                      widget.post.imageUrl!,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          color: Colors.grey.shade300,
                          child: const Icon(
                            Icons.image_not_supported,
                            size: 50,
                            color: Colors.grey,
                          ),
                        );
                      },
                    )
                  else
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Colors.blue.shade400, Colors.purple.shade400],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                      ),
                      child: const Icon(
                        Icons.restaurant,
                        size: 80,
                        color: Colors.white,
                      ),
                    ),
                  // Gradient overlay
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.black.withOpacity(0.7),
                          Colors.transparent,
                          Colors.black.withOpacity(0.7),
                        ],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                  ),
                  // Title overlay
                  Positioned(
                    bottom: 20,
                    left: 20,
                    right: 20,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (widget.post.foodName != null)
                          Text(
                            widget.post.foodName!,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              shadows: [
                                Shadow(
                                  offset: Offset(0, 2),
                                  blurRadius: 4,
                                  color: Colors.black54,
                                ),
                              ],
                            ),
                          ),
                        if (widget.post.title.isNotEmpty)
                          Text(
                            widget.post.title,
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 16,
                              shadows: [
                                Shadow(
                                  offset: Offset(0, 1),
                                  blurRadius: 2,
                                  color: Colors.black54,
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            leading: Container(
              margin: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.9),
                borderRadius: BorderRadius.circular(12),
              ),
              child: IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.black87),
                onPressed: () => Navigator.pop(context),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Description Card
                    if (widget.post.description.isNotEmpty)
                      Container(
                        width: double.infinity,
                        margin: const EdgeInsets.only(bottom: 16),
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 20,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: Text(
                          widget.post.description,
                          style: const TextStyle(
                            fontSize: 16,
                            height: 1.6,
                            color: Colors.black87,
                          ),
                        ),
                      ),

                    // Nutrition Card
                    _buildNutritionCard(),

                    // Ingredients Card
                    _buildIngredientsCard(),

                    // Target Users Card
                    _buildTargetUsersCard(),

                    // Interactions Section
                    Container(
                      margin: const EdgeInsets.only(bottom: 16),
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 20,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: AnimatedBuilder(
                        animation: _scaleAnimation,
                        builder: (context, child) {
                          return Transform.scale(
                            scale: _isLiked ? _scaleAnimation.value : 1.0,
                            child: PostInteractionsRow(
                              likes: _likes,
                              isLiked: _isLiked,
                              onToggleLike: _toggleLike,
                              getLikeSummary: _getLikeSummary,
                            ),
                          );
                        },
                      ),
                    ),

                    // Comments Section
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 20,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: PostCommentSection(commentStream: _commentStream()),
                    ),

                    const SizedBox(height: 100), // Space for comment input
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 20,
              offset: const Offset(0, -8),
            ),
          ],
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: CommentInputField(
              commentController: _commentController,
              onSubmitComment: _submitComment,
            ),
          ),
        ),
      ),
    );
  }
}