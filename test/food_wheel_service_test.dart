import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:my_app/data/mock_food_repository.dart';
import 'package:my_app/services/food_search_service.dart';
import 'package:my_app/services/food_wheel_service.dart';

void main() {
  const service = FoodWheelService();

  test('gets wheel candidates from search filters before spinning', () {
    final candidates = service.getCandidates(
      foods: MockFoodRepository.allFoods,
      filters: const FoodSearchFilters(
        tags: {'低脂'},
        maxPrice: 150,
        maxDistanceMeters: 1000,
      ),
    );

    expect(candidates, isNotEmpty);
    expect(candidates.every((food) => food.tags.contains('低脂')), isTrue);
    expect(candidates.every((food) => food.price <= 150), isTrue);
    expect(candidates.every((food) => food.distanceMeters <= 1000), isTrue);
  });

  test('spin returns null when there are no candidates', () {
    final selectedFood = service.spin(candidates: const []);

    expect(selectedFood, isNull);
  });

  test('spin picks a food from the provided candidate list', () {
    final candidates = MockFoodRepository.expiringFoods;

    final selectedFood = service.spin(
      candidates: candidates,
      random: Random(3),
    );

    expect(candidates, contains(selectedFood));
  });
}
