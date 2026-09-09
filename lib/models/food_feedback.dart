class FoodFeedback {
  const FoodFeedback({
    required this.foodId,
    required this.rating,
    required this.tags,
    required this.createdAt,
  });

  final String foodId;
  final int rating;
  final List<String> tags;
  final DateTime createdAt;

  String get ratingLabel => '$rating 星';

  String get tagSummary => tags.isEmpty ? '未選擇標籤' : tags.join('、');

  Map<String, Object?> toJson() {
    return {
      'foodId': foodId,
      'rating': rating,
      'tags': tags,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory FoodFeedback.fromJson(Map<String, Object?> json) {
    return FoodFeedback(
      foodId: json['foodId'] as String? ?? '',
      rating: (json['rating'] as int? ?? 0).clamp(1, 5).toInt(),
      tags: (json['tags'] as List?)?.whereType<String>().toList() ?? const [],
      createdAt:
          DateTime.tryParse(json['createdAt'] as String? ?? '') ??
          DateTime.now(),
    );
  }
}
