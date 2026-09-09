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
      final bScore = scoreFood(b, preference).totalScore;
      final aScore = scoreFood(a, preference).totalScore;
      return bScore.compareTo(aScore);
    });

    return candidates;
  }

  RecommendationScoreBreakdown scoreFood(
    FoodItem food,
    UserPreference preference,
  ) {
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
    final totalScore =
        preferenceScore * 0.4 +
        distanceScore.clamp(0, 1) * 0.2 +
        budgetScore.clamp(0, 1) * 0.2 +
        ecoScore * 0.2;

    return RecommendationScoreBreakdown(
      preferenceScore: preferenceScore.clamp(0, 1).toDouble(),
      distanceScore: distanceScore.clamp(0, 1).toDouble(),
      budgetScore: budgetScore.clamp(0, 1).toDouble(),
      ecoScore: ecoScore.clamp(0, 1).toDouble(),
      totalScore: totalScore.clamp(0, 1).toDouble(),
    );
  }
}

class RecommendationScoreBreakdown {
  const RecommendationScoreBreakdown({
    required this.preferenceScore,
    required this.distanceScore,
    required this.budgetScore,
    required this.ecoScore,
    required this.totalScore,
  });

  final double preferenceScore;
  final double distanceScore;
  final double budgetScore;
  final double ecoScore;
  final double totalScore;

  int get preferencePercent => _toPercent(preferenceScore);

  int get distancePercent => _toPercent(distanceScore);

  int get budgetPercent => _toPercent(budgetScore);

  int get ecoPercent => _toPercent(ecoScore);

  int get totalPercent => _toPercent(totalScore);

  static int _toPercent(double value) {
    return (value * 100).round().clamp(0, 100);
  }
}
