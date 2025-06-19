class Post {
  final String id;
  final String title;
  final String imageUrl;
  final String author;
  final String authorId;
  final String authorAvatar;
  final String description;
  final DateTime createdAt;
  final List<String> likes;
  final List<Comment> comments;

  // Health and nutrition information
  final List<String> ingredients;
  final Map<String, double>
  nutritionInfo; // calories, protein, carbs, fat, fiber, etc.
  final List<String> dietaryTags; // vegetarian, vegan, gluten-free, keto, etc.
  final String mealType; // breakfast, lunch, dinner, snack
  final int prepTime; // in minutes
  final int servings;
  final String difficulty; // easy, medium, hard
  final List<String> healthBenefits;
  final double averageRating;
  final int totalRatings;

  Post({
    required this.id,
    required this.title,
    required this.imageUrl,
    required this.author,
    required this.authorId,
    required this.description,
    this.authorAvatar = '',
    DateTime? createdAt,
    List<String>? likes,
    List<Comment>? comments,
    List<String>? ingredients,
    Map<String, double>? nutritionInfo,
    List<String>? dietaryTags,
    this.mealType = 'meal',
    this.prepTime = 0,
    this.servings = 1,
    this.difficulty = 'medium',
    List<String>? healthBenefits,
    this.averageRating = 0.0,
    this.totalRatings = 0,
  }) : createdAt = createdAt ?? DateTime.now(),
       likes = likes ?? [],
       comments = comments ?? [],
       ingredients = ingredients ?? [],
       nutritionInfo = nutritionInfo ?? {},
       dietaryTags = dietaryTags ?? [],
       healthBenefits = healthBenefits ?? [];

  Post copyWith({
    String? id,
    String? title,
    String? imageUrl,
    String? author,
    String? authorId,
    String? authorAvatar,
    String? description,
    DateTime? createdAt,
    List<String>? likes,
    List<Comment>? comments,
    List<String>? ingredients,
    Map<String, double>? nutritionInfo,
    List<String>? dietaryTags,
    String? mealType,
    int? prepTime,
    int? servings,
    String? difficulty,
    List<String>? healthBenefits,
    double? averageRating,
    int? totalRatings,
  }) {
    return Post(
      id: id ?? this.id,
      title: title ?? this.title,
      imageUrl: imageUrl ?? this.imageUrl,
      author: author ?? this.author,
      authorId: authorId ?? this.authorId,
      authorAvatar: authorAvatar ?? this.authorAvatar,
      description: description ?? this.description,
      createdAt: createdAt ?? this.createdAt,
      likes: likes ?? this.likes,
      comments: comments ?? this.comments,
      ingredients: ingredients ?? this.ingredients,
      nutritionInfo: nutritionInfo ?? this.nutritionInfo,
      dietaryTags: dietaryTags ?? this.dietaryTags,
      mealType: mealType ?? this.mealType,
      prepTime: prepTime ?? this.prepTime,
      servings: servings ?? this.servings,
      difficulty: difficulty ?? this.difficulty,
      healthBenefits: healthBenefits ?? this.healthBenefits,
      averageRating: averageRating ?? this.averageRating,
      totalRatings: totalRatings ?? this.totalRatings,
    );
  }

  // Helper method to get nutrition per serving
  Map<String, double> getNutritionPerServing() {
    if (servings <= 0) return nutritionInfo;

    return nutritionInfo.map((key, value) => MapEntry(key, value / servings));
  }

  // Helper method to check if post matches dietary preferences
  bool matchesDietaryPreferences(List<String> userPreferences) {
    return userPreferences.any((pref) => dietaryTags.contains(pref));
  }
}

class Comment {
  final String id;
  final String authorId;
  final String authorName;
  final String authorAvatar;
  final String content;
  final DateTime createdAt;
  final DateTime? editedAt;
  final List<Comment> replies;
  final List<String> likes;
  final bool isVerifiedNutritionist; // For verified health professionals
  final double? rating; // Optional rating for the recipe (1-5 stars)

  Comment({
    required this.id,
    required this.authorId,
    required this.authorName,
    required this.content,
    this.authorAvatar = '',
    DateTime? createdAt,
    this.editedAt,
    List<Comment>? replies,
    List<String>? likes,
    this.isVerifiedNutritionist = false,
    this.rating,
  }) : createdAt = createdAt ?? DateTime.now(),
       replies = replies ?? [],
       likes = likes ?? [];

  Comment copyWith({
    String? id,
    String? authorId,
    String? authorName,
    String? authorAvatar,
    String? content,
    DateTime? createdAt,
    DateTime? editedAt,
    List<Comment>? replies,
    List<String>? likes,
    bool? isVerifiedNutritionist,
    double? rating,
  }) {
    return Comment(
      id: id ?? this.id,
      authorId: authorId ?? this.authorId,
      authorName: authorName ?? this.authorName,
      authorAvatar: authorAvatar ?? this.authorAvatar,
      content: content ?? this.content,
      createdAt: createdAt ?? this.createdAt,
      editedAt: editedAt ?? this.editedAt,
      replies: replies ?? this.replies,
      likes: likes ?? this.likes,
      isVerifiedNutritionist:
          isVerifiedNutritionist ?? this.isVerifiedNutritionist,
      rating: rating ?? this.rating,
    );
  }
}
