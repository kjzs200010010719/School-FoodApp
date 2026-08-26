import 'package:my_app/models/food_item.dart';
import 'package:my_app/models/user_preference.dart';

class RecommendationService {
  const RecommendationService();

  List<FoodItem> getRecommendations({
    required List<FoodItem> foods,
    required UserPreference preference,
    DateTime? now,
  }) {
    final today = now ?? DateTime.now();
    final candidates = foods.where((food) {
      final isOpenToday = food.isOpenOn(today);
      final isInBudget =
          food.price >= preference.budgetMin &&
          food.price <= preference.budgetMax;
      final isNearby = food.distanceMeters <= preference.distanceLimitMeters;
      final avoidsRestrictedIngredients = preference.avoidIngredients.every(
        (ingredient) => !food.ingredients.contains(ingredient),
      );

      return isOpenToday &&
          isInBudget &&
          isNearby &&
          avoidsRestrictedIngredients;
    }).toList();

    candidates.sort((a, b) {
      final bScore = _scoreFood(b, preference);
      final aScore = _scoreFood(a, preference);
      return bScore.compareTo(aScore);
    });

    return candidates;
  }

  double _scoreFood(FoodItem food, UserPreference preference) {
    final tagMatches = food.tags
        .where((tag) => preference.preferredTags.contains(tag))
        .length;
    final preferenceScore = preference.preferredTags.isEmpty
        ? 0.5
        : tagMatches / preference.preferredTags.length;
    final distanceScore =
        1 - (food.distanceMeters / preference.distanceLimitMeters);
    final budgetCenter = (preference.budgetMin + preference.budgetMax) / 2;
    final budgetScore = 1 - ((food.price - budgetCenter).abs() / budgetCenter);
    final ecoScore = preference.wasteReductionEnabled
        ? food.ecoPriorityScore
        : 0;

    return preferenceScore * 0.4 +
        distanceScore.clamp(0, 1) * 0.2 +
        budgetScore.clamp(0, 1) * 0.2 +
        ecoScore * 0.2;
  }
}
