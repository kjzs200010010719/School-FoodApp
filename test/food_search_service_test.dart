import 'package:flutter_test/flutter_test.dart';
import 'package:my_app/data/mock_food_repository.dart';
import 'package:my_app/services/food_search_service.dart';

void main() {
  const service = FoodSearchService();

  test('search matches food name, store, tag, and ingredient text', () {
    final foods = MockFoodRepository.allFoods;

    expect(
      service.search(foods: foods, query: '雞胸').map((food) => food.name),
      contains('舒肥雞胸餐盒'),
    );
    expect(
      service.search(foods: foods, query: '晨光').map((food) => food.name),
      isNotEmpty,
    );
    expect(
      service.search(foods: foods, query: '低脂').map((food) => food.name),
      isNotEmpty,
    );
  });

  test('filters by category, budget, distance, and expiring status', () {
    final results = service.search(
      foods: MockFoodRepository.allFoods,
      filters: const FoodSearchFilters(
        categories: {'便當'},
        maxPrice: 100,
        maxDistanceMeters: 300,
        expiringOnly: true,
      ),
    );

    expect(results, isNotEmpty);
    expect(results.every((food) => food.category == '便當'), isTrue);
    expect(results.every((food) => food.price <= 100), isTrue);
    expect(results.every((food) => food.distanceMeters <= 300), isTrue);
    expect(results.every((food) => food.isExpiringSoon), isTrue);
  });
}
