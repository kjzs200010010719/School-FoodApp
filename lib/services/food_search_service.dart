import 'package:my_app/models/food_item.dart';

class FoodSearchFilters {
  const FoodSearchFilters({
    this.categories = const {},
    this.tags = const {},
    this.maxPrice,
    this.maxDistanceMeters,
    this.expiringOnly = false,
  });

  final Set<String> categories;
  final Set<String> tags;
  final int? maxPrice;
  final int? maxDistanceMeters;
  final bool expiringOnly;

  FoodSearchFilters copyWith({
    Set<String>? categories,
    Set<String>? tags,
    int? maxPrice,
    int? maxDistanceMeters,
    bool? expiringOnly,
    bool clearMaxPrice = false,
    bool clearMaxDistance = false,
  }) {
    return FoodSearchFilters(
      categories: categories ?? this.categories,
      tags: tags ?? this.tags,
      maxPrice: clearMaxPrice ? null : maxPrice ?? this.maxPrice,
      maxDistanceMeters: clearMaxDistance
          ? null
          : maxDistanceMeters ?? this.maxDistanceMeters,
      expiringOnly: expiringOnly ?? this.expiringOnly,
    );
  }
}

class FoodSearchService {
  const FoodSearchService();

  List<FoodItem> search({
    required List<FoodItem> foods,
    String query = '',
    FoodSearchFilters filters = const FoodSearchFilters(),
  }) {
    final keyword = query.trim().toLowerCase();

    final results = foods.where((food) {
      if (keyword.isNotEmpty && !_matchesKeyword(food, keyword)) {
        return false;
      }

      if (filters.categories.isNotEmpty &&
          !filters.categories.contains(food.category)) {
        return false;
      }

      if (filters.tags.isNotEmpty &&
          !filters.tags.any((tag) => food.tags.contains(tag))) {
        return false;
      }

      if (filters.maxPrice != null && food.price > filters.maxPrice!) {
        return false;
      }

      if (filters.maxDistanceMeters != null &&
          food.distanceMeters > filters.maxDistanceMeters!) {
        return false;
      }

      if (filters.expiringOnly && !food.isExpiringSoon) {
        return false;
      }

      return true;
    }).toList();

    results.sort((a, b) {
      final expiringCompare = b.ecoPriorityScore.compareTo(a.ecoPriorityScore);
      if (expiringCompare != 0) {
        return expiringCompare;
      }

      return a.distanceMeters.compareTo(b.distanceMeters);
    });

    return results;
  }

  bool _matchesKeyword(FoodItem food, String keyword) {
    final searchableText = [
      food.name,
      food.storeName,
      food.category,
      ...food.tags,
      ...food.ingredients,
      ...food.nutritionTags,
    ].join(' ').toLowerCase();

    return searchableText.contains(keyword);
  }
}
