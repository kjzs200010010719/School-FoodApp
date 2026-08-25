import 'package:flutter_test/flutter_test.dart';
import 'package:my_app/data/mock_food_repository.dart';
import 'package:my_app/models/user_preference.dart';
import 'package:my_app/services/recommendation_service.dart';

void main() {
  test('mock foods have two to three preference tags', () {
    expect(
      MockFoodRepository.allFoods.every(
        (food) => food.tags.length >= 2 && food.tags.length <= 3,
      ),
      isTrue,
    );
  });

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

  test(
    'recommendations prioritize foods matching selected preference tags',
    () {
      const service = RecommendationService();
      const vegetarianPreference = UserPreference(
        dietaryPreferences: ['素食'],
        budgetMin: 0,
        budgetMax: 200,
        distanceLimitMeters: 1500,
        preferredTags: ['素食'],
        avoidIngredients: [],
        wasteReductionEnabled: false,
      );

      final recommendations = service.getRecommendations(
        foods: MockFoodRepository.allFoods,
        preference: vegetarianPreference,
      );

      expect(recommendations, isNotEmpty);
      expect(recommendations.first.tags, contains('素食'));
    },
  );
}
