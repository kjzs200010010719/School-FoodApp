import 'package:flutter_test/flutter_test.dart';
import 'package:my_app/main.dart';

void main() {
  testWidgets('renders home screen content', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());

    expect(find.text('膳解人意'), findsOneWidget);
    expect(find.text('今日推薦'), findsOneWidget);
    expect(find.text('即期優惠'), findsOneWidget);
    expect(find.text('查看推薦'), findsOneWidget);
  });

  testWidgets('opens food detail from home recommendation card', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const MyApp());

    await tester.tap(find.text('舒肥雞胸餐盒'));
    await tester.pumpAndSettle();

    expect(find.text('餐點詳情'), findsOneWidget);
    expect(find.text('推薦原因'), findsOneWidget);
  });

  testWidgets('opens search screen from home search field', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const MyApp());

    await tester.tap(find.text('搜尋你想吃的餐點、店家...'));
    await tester.pumpAndSettle();

    expect(find.text('搜尋餐點'), findsOneWidget);
    expect(find.text('餐點、店家、食材或標籤'), findsOneWidget);
  });

  testWidgets('opens wheel screen from home quick action', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const MyApp());

    await tester.tap(find.text('轉盤決定'));
    await tester.pumpAndSettle();

    expect(find.text('食物轉盤'), findsOneWidget);
    expect(find.text('轉盤條件'), findsOneWidget);
  });
}
