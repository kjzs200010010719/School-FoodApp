import 'package:flutter_test/flutter_test.dart';
import 'package:my_app/data/mock_food_repository.dart';
import 'package:my_app/models/user_preference.dart';
import 'package:my_app/services/recommendation_service.dart';

void main() {
  test(
    'recommendations keep nearby foods under budget and include expiring items',
    () {
      const service = RecommendationService();

      final recommendations = service.getRecommendations(
        foods: MockFoodRepository.allFoods,
        preference: UserPreference.defaultPreference,
      );

      expect(recommendations, isNotEmpty);
      expect(
        recommendations.every(
          (food) =>
              food.price <= UserPreference.defaultPreference.budgetMax &&
              food.distanceMeters <=
                  UserPreference.defaultPreference.distanceLimitMeters,
        ),
        isTrue,
      );
      expect(recommendations.any((food) => food.isExpiringSoon), isTrue);
    },
  );
}
