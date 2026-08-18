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
      contains('鮪魚三明治'),
    );
    expect(
      service.search(foods: foods, query: '低脂').map((food) => food.name),
      containsAll(['鮭魚藜麥沙拉', '水果優格杯']),
    );
  });

  test('filters by category, budget, distance, and expiring status', () {
    final results = service.search(
      foods: MockFoodRepository.allFoods,
      filters: const FoodSearchFilters(
        categories: {'早餐'},
        maxPrice: 80,
        maxDistanceMeters: 500,
        expiringOnly: true,
      ),
    );

    expect(results.map((food) => food.name), ['鮪魚三明治']);
  });
}
