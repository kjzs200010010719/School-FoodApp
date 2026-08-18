import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:my_app/data/mock_food_repository.dart';
import 'package:my_app/screens/food_detail_screen.dart';

void main() {
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
}
