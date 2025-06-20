class Post {
  final String? id;
  final String title;
  final String imageUrl;
  final String author;
  final String description;
  final int likes;

  // Optional extra fields stored in Firestore but not strictly required in model
  final String? foodName;
  final String? ingredients;
  final String? calories;
  final String? carbs;
  final String? protein;
  final String? fats;
  final List<String>? targetUsers;

  Post({
    this.id,
    required this.title,
    required this.imageUrl,
    required this.author,
    required this.description,
    required this.likes,
    this.foodName,
    this.ingredients,
    this.calories,
    this.carbs,
    this.protein,
    this.fats,
    this.targetUsers,
  });

  factory Post.fromMap(Map<String, dynamic> data, String docId) {
    return Post(
      id: docId,
      title: data['title'] ?? '',
      imageUrl: data['imageUrl'] ?? '',
      author: data['author'] ?? '',
      description: data['description'] ?? '',
      likes: data['likes'] ?? 0,
      foodName: data['foodName'],
      ingredients: data['ingredients'],
      calories: data['calories'],
      carbs: data['carbs'],
      protein: data['protein'],
      fats: data['fats'],
      targetUsers: List<String>.from(data['targetUsers'] ?? []),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'imageUrl': imageUrl,
      'author': author,
      'description': description,
      'likes': likes,
      'foodName': foodName,
      'ingredients': ingredients,
      'calories': calories,
      'carbs': carbs,
      'protein': protein,
      'fats': fats,
      'targetUsers': targetUsers,
    };
  }
}
