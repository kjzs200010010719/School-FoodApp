import 'package:flutter_test/flutter_test.dart';
import 'package:my_app/data/mock_food_repository.dart';
import 'package:my_app/models/user_preference.dart';
import 'package:my_app/services/recommendation_service.dart';

void main() {
  final wednesday = DateTime(2026, 8, 26);

  test('mock repository contains 100 foods', () {
    expect(MockFoodRepository.allFoods, hasLength(100));
  });

  test('mock foods have two to three preference tags', () {
    expect(
      MockFoodRepository.allFoods.every(
        (food) => food.tags.length >= 2 && food.tags.length <= 3,
      ),
      isTrue,
    );
  });

  test('mock foods have valid business weekdays', () {
    expect(
      MockFoodRepository.allFoods.every(
        (food) =>
            food.businessWeekdays.isNotEmpty &&
            food.businessWeekdays.every(
              (weekday) =>
                  weekday >= DateTime.monday && weekday <= DateTime.sunday,
            ),
      ),
      isTrue,
    );
  });

  test(
    'recommendations keep open nearby foods under budget and include expiring items',
    () {
      const service = RecommendationService();

      final recommendations = service.getRecommendations(
        foods: MockFoodRepository.allFoods,
        preference: UserPreference.defaultPreference,
        now: wednesday,
      );

      expect(recommendations, isNotEmpty);
      expect(
        recommendations.every(
          (food) =>
              food.isOpenOn(wednesday) &&
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
        now: wednesday,
      );

      expect(recommendations, isNotEmpty);
      expect(recommendations.first.tags, contains('素食'));
    },
  );

  test('recommendations exclude foods closed on the selected date', () {
    const service = RecommendationService();
    final closedFood = MockFoodRepository.allFoods.first.copyWith(
      businessWeekdays: const [DateTime.thursday],
    );
    final openFood = MockFoodRepository.allFoods[1].copyWith(
      businessWeekdays: const [DateTime.wednesday],
    );

    final recommendations = service.getRecommendations(
      foods: [closedFood, openFood],
      preference: const UserPreference(
        dietaryPreferences: [],
        budgetMin: 0,
        budgetMax: 300,
        distanceLimitMeters: 3000,
        preferredTags: [],
        avoidIngredients: [],
        wasteReductionEnabled: false,
      ),
      now: wednesday,
    );

    expect(recommendations, [openFood]);
  });
}
