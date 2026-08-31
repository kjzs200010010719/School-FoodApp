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

  test('keeps recent search logs newest first without duplicates', () {
    service.addSearchLog(keyword: '雞', filterSummary: '高蛋白');
    service.addSearchLog(keyword: '沙拉', filterSummary: '低脂');
    service.addSearchLog(keyword: '雞', filterSummary: '高蛋白');

    expect(service.searchLogs.map((log) => log.keyword), ['雞', '沙拉']);
    expect(service.searchLogs.first.filterSummary, '高蛋白');
  });

  test('restores search logs from local storage', () async {
    service.addSearchLog(keyword: '素食', filterSummary: '均衡 / 150 元內');

    await service.initialize();

    expect(service.searchLogs, hasLength(1));
    expect(service.searchLogs.first.keyword, '素食');
    expect(service.searchLogs.first.filterSummary, '均衡 / 150 元內');
  });

  test('clears search logs', () {
    service.addSearchLog(keyword: '雞', filterSummary: '高蛋白');

    service.clearSearchLogs();

    expect(service.searchLogs, isEmpty);
  });

  test('adds cart items and updates quantities', () {
    final food = MockFoodRepository.allFoods.first;

    service.addToCart(food);
    service.addToCart(food);

    expect(service.isInCart(food.id), isTrue);
    expect(service.cartQuantity(food.id), 2);
    expect(service.cartItems, hasLength(1));
    expect(service.cartTotalQuantity, 2);
    expect(service.cartTotalPrice, food.price * 2);

    service.decreaseCartItem(food);

    expect(service.cartQuantity(food.id), 1);
  });

  test('checkout stores purchase record and clears cart', () {
    final firstFood = MockFoodRepository.allFoods.first;
    final secondFood = MockFoodRepository.allFoods[1];

    service.addToCart(firstFood);
    service.addToCart(secondFood);
    service.addToCart(secondFood);

    final record = service.checkoutCart();

    expect(record, isNotNull);
    expect(service.cartItems, isEmpty);
    expect(service.purchaseRecords, hasLength(1));
    expect(service.purchaseRecords.first.totalQuantity, 3);
    expect(
      service.purchaseRecords.first.totalPrice,
      firstFood.price + secondFood.price * 2,
    );
  });
}
