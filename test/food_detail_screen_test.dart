import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:my_app/data/mock_food_repository.dart';
import 'package:my_app/screens/food_detail_screen.dart';
import 'package:my_app/services/user_activity_service.dart';
import 'package:my_app/widgets/food_photo.dart';

void main() {
  setUp(() {
    UserActivityService.instance.clearForTesting();
  });

  testWidgets('renders food detail information', (WidgetTester tester) async {
    final food = MockFoodRepository.allFoods.first;

    await tester.pumpWidget(MaterialApp(home: FoodDetailScreen(food: food)));

    expect(find.text('餐點資訊'), findsOneWidget);
    expect(find.text(food.name), findsOneWidget);
    expect(find.byType(FoodPhoto), findsOneWidget);

    await tester.scrollUntilVisible(
      find.text('推薦原因'),
      300,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pumpAndSettle();

    expect(find.text('推薦原因'), findsOneWidget);
    expect(find.text('減廢分數', skipOffstage: false), findsOneWidget);

    await tester.scrollUntilVisible(
      find.text('營養估算'),
      300,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pumpAndSettle();

    expect(find.text('營養估算'), findsOneWidget);
    expect(find.text(food.caloriesLabel), findsOneWidget);

    await tester.scrollUntilVisible(
      find.text('食材資訊'),
      300,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pumpAndSettle();

    expect(find.text('食材資訊'), findsOneWidget);

    await tester.scrollUntilVisible(
      find.text('店家資訊'),
      300,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pumpAndSettle();

    expect(find.text('店家資訊'), findsOneWidget);
  });

  testWidgets('toggles favorite button label in food detail', (
    WidgetTester tester,
  ) async {
    final food = MockFoodRepository.allFoods.first;

    await tester.pumpWidget(MaterialApp(home: FoodDetailScreen(food: food)));
    final favoriteButton = find.text('加入收藏');
    await tester.scrollUntilVisible(
      favoriteButton,
      180,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.ensureVisible(favoriteButton);
    await tester.pumpAndSettle();

    expect(find.text('加入收藏'), findsOneWidget);
    expect(find.text('加入購物車'), findsOneWidget);

    await tester.tap(favoriteButton);
    await tester.pump();

    expect(find.text('取消收藏'), findsOneWidget);

    await tester.tap(find.text('取消收藏'));
    await tester.pump();

    expect(find.text('加入收藏'), findsOneWidget);
  });

  testWidgets('adds food to cart and opens cart screen', (
    WidgetTester tester,
  ) async {
    final food = MockFoodRepository.allFoods.first;

    await tester.pumpWidget(MaterialApp(home: FoodDetailScreen(food: food)));
    final addToCartButton = find.text('加入購物車');
    await tester.scrollUntilVisible(
      addToCartButton,
      180,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.ensureVisible(addToCartButton);
    await tester.pumpAndSettle();

    await tester.tap(addToCartButton);
    await tester.pump();

    expect(find.text('查看購物車'), findsOneWidget);

    await tester.tap(find.text('查看購物車'));
    await tester.pumpAndSettle();

    expect(find.text('購物車'), findsOneWidget);
    expect(find.text(food.name), findsOneWidget);
  });
}
