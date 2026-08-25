import 'package:flutter_test/flutter_test.dart';
import 'package:my_app/data/mock_food_repository.dart';
import 'package:my_app/services/user_activity_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  final service = UserActivityService.instance;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await service.initialize();
    service.clearForTesting();
  });

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

  test('restores favorite and history food ids from local storage', () async {
    final firstFood = MockFoodRepository.allFoods.first;
    final secondFood = MockFoodRepository.allFoods[1];

    service.toggleFavorite(firstFood);
    service.addHistory(secondFood);

    await service.initialize();

    expect(service.isFavorite(firstFood.id), isTrue);
    expect(service.history.map((food) => food.id), [secondFood.id]);
  });
}
