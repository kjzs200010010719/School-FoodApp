import 'dart:math';

import 'package:my_app/models/food_item.dart';
import 'package:my_app/services/food_search_service.dart';

class FoodWheelService {
  const FoodWheelService({this.searchService = const FoodSearchService()});

  final FoodSearchService searchService;

  List<FoodItem> getCandidates({
    required List<FoodItem> foods,
    FoodSearchFilters filters = const FoodSearchFilters(),
    DateTime? now,
  }) {
    if (!_hasActiveFilters(filters)) {
      return const [];
    }

    final today = now ?? DateTime.now();
    return searchService
        .search(foods: foods, filters: filters)
        .where((food) => food.isOpenOn(today))
        .toList();
  }

  FoodItem? spin({required List<FoodItem> candidates, Random? random}) {
    if (candidates.isEmpty) {
      return null;
    }

    final randomSource = random ?? Random();
    return candidates[randomSource.nextInt(candidates.length)];
  }

  bool _hasActiveFilters(FoodSearchFilters filters) {
    return filters.categories.isNotEmpty ||
        filters.tags.isNotEmpty ||
        filters.maxPrice != null ||
        filters.maxDistanceMeters != null ||
        filters.expiringOnly;
  }
}
