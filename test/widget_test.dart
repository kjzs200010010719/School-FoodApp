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
}
