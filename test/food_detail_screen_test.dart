import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:my_app/data/mock_food_repository.dart';
import 'package:my_app/screens/food_detail_screen.dart';
import 'package:my_app/services/user_activity_service.dart';

void main() {
  setUp(() {
    UserActivityService.instance.clearForTesting();
  });

  testWidgets('renders food detail information', (WidgetTester tester) async {
    final food = MockFoodRepository.allFoods.first;

    await tester.pumpWidget(MaterialApp(home: FoodDetailScreen(food: food)));

    expect(find.text('餐點詳情'), findsOneWidget);
    expect(find.text(food.name), findsOneWidget);
    expect(find.text('推薦原因'), findsOneWidget);

    await tester.drag(find.byType(ListView), const Offset(0, -500));
    await tester.pumpAndSettle();

    expect(find.text('食材資訊'), findsOneWidget);
    expect(find.text('店家資訊'), findsOneWidget);
    expect(find.text('減廢分數'), findsOneWidget);
  });

  testWidgets('toggles favorite button label in food detail', (
    WidgetTester tester,
  ) async {
    final food = MockFoodRepository.allFoods.first;

    await tester.pumpWidget(MaterialApp(home: FoodDetailScreen(food: food)));
    await tester.scrollUntilVisible(
      find.text('加入收藏'),
      300,
      scrollable: find.byType(Scrollable).first,
    );

    expect(find.text('加入收藏'), findsOneWidget);

    await tester.tap(find.text('加入收藏'));
    await tester.pump();

    expect(find.text('取消收藏'), findsOneWidget);

    await tester.tap(find.text('取消收藏'));
    await tester.pump();

    expect(find.text('加入收藏'), findsOneWidget);
  });
}
