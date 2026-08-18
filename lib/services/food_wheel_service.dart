import 'dart:math';

import 'package:my_app/models/food_item.dart';
import 'package:my_app/services/food_search_service.dart';

class FoodWheelService {
  const FoodWheelService({this.searchService = const FoodSearchService()});

  final FoodSearchService searchService;

  List<FoodItem> getCandidates({
    required List<FoodItem> foods,
    FoodSearchFilters filters = const FoodSearchFilters(),
  }) {
    return searchService.search(foods: foods, filters: filters);
  }

  FoodItem? spin({required List<FoodItem> candidates, Random? random}) {
    if (candidates.isEmpty) {
      return null;
    }

    final randomSource = random ?? Random();
    final totalWeight = candidates.fold<double>(
      0,
      (sum, food) => sum + _weight(food),
    );
    var ticket = randomSource.nextDouble() * totalWeight;

    for (final food in candidates) {
      ticket -= _weight(food);
      if (ticket <= 0) {
        return food;
      }
    }

    return candidates.last;
  }

  double _weight(FoodItem food) {
    final ecoWeight = food.ecoPriorityScore * 2;
    final stockWeight = food.stockCount > 0 ? 0.4 : 0;
    final expiringWeight = food.isExpiringSoon ? 1.2 : 0;
    return 1 + ecoWeight + stockWeight + expiringWeight;
  }
}
