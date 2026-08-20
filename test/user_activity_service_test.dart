import 'package:flutter_test/flutter_test.dart';
import 'package:my_app/data/mock_food_repository.dart';
import 'package:my_app/services/user_activity_service.dart';

void main() {
  final service = UserActivityService.instance;

  setUp(service.clearForTesting);

  test('mock foods are not favorite by default', () {
    expect(
      MockFoodRepository.allFoods.every((food) => !food.isFavorite),
      isTrue,
    );
  });

  test('toggles favorite foods', () {
    final food = MockFoodRepository.allFoods.first;

    service.toggleFavorite(food);

    expect(service.isFavorite(food.id), isTrue);
    expect(service.favorites, hasLength(1));

    service.toggleFavorite(food);

    expect(service.isFavorite(food.id), isFalse);
    expect(service.favorites, isEmpty);
  });

  test('keeps browsing history newest first without duplicates', () {
    final firstFood = MockFoodRepository.allFoods.first;
    final secondFood = MockFoodRepository.allFoods[1];

    service.addHistory(firstFood);
    service.addHistory(secondFood);
    service.addHistory(firstFood);

    expect(service.history.map((food) => food.id), [
      firstFood.id,
      secondFood.id,
    ]);
  });
}
