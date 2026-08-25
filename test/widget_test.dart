import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:my_app/main.dart';
import 'package:my_app/services/user_activity_service.dart';
import 'package:my_app/services/user_profile_service.dart';

void main() {
  setUp(() {
    UserActivityService.instance.clearForTesting();
    UserProfileService.instance.clearForTesting();
  });

  testWidgets('renders home screen content', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());

    expect(find.text('膳解人意'), findsOneWidget);
    expect(find.text('今日推薦'), findsOneWidget);
    expect(find.text('即期優惠'), findsWidgets);
    expect(find.text('查看推薦'), findsOneWidget);
  });

  testWidgets('opens food detail from home recommendation card', (
    WidgetTester tester,
  ) async {
    UserProfileService.instance.loginWithDemo();
    await tester.pumpWidget(const MyApp());

    await tester.scrollUntilVisible(
      find.text('舒肥雞胸餐盒'),
      200,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.tap(find.text('舒肥雞胸餐盒'));
    await tester.pumpAndSettle();

    expect(find.text('餐點詳情'), findsOneWidget);
    expect(find.text('推薦原因'), findsOneWidget);
  });

  testWidgets('opens search screen after submitting home search', (
    WidgetTester tester,
  ) async {
    UserProfileService.instance.loginWithDemo();
    await tester.pumpWidget(const MyApp());

    await tester.enterText(find.byType(TextField).first, '雞');
    await tester.tap(find.byIcon(Icons.arrow_forward_rounded));
    await tester.pumpAndSettle();

    expect(find.text('搜尋餐點'), findsOneWidget);
    expect(find.text('餐點、店家、食材或標籤'), findsOneWidget);
    expect(find.text('舒肥雞胸餐盒'), findsOneWidget);
  });

  testWidgets('opens wheel screen from home quick action', (
    WidgetTester tester,
  ) async {
    UserProfileService.instance.loginWithDemo();
    await tester.pumpWidget(const MyApp());

    await tester.tap(find.text('轉盤決定'));
    await tester.pumpAndSettle();

    expect(find.text('食物轉盤'), findsOneWidget);
    expect(find.text('轉盤條件'), findsOneWidget);

    await tester.scrollUntilVisible(
      find.text('請先設定轉盤條件，系統會列出符合條件的候選餐點。'),
      200,
      scrollable: find.byType(Scrollable).first,
    );
    expect(find.text('請先設定轉盤條件，系統會列出符合條件的候選餐點。'), findsOneWidget);
  });

  testWidgets('opens collection screen from bottom navigation', (
    WidgetTester tester,
  ) async {
    UserProfileService.instance.loginWithDemo();
    await tester.pumpWidget(const MyApp());

    await tester.tap(find.text('收藏').last);
    await tester.pumpAndSettle();

    expect(find.text('收藏與紀錄'), findsOneWidget);
    expect(find.text('尚未收藏餐點'), findsOneWidget);
  });

  testWidgets('shows search logs in collection screen', (
    WidgetTester tester,
  ) async {
    UserProfileService.instance.loginWithDemo();
    UserActivityService.instance.addSearchLog(
      keyword: '雞',
      filterSummary: '高蛋白',
    );
    await tester.pumpWidget(const MyApp());

    await tester.tap(find.text('收藏').last);
    await tester.pumpAndSettle();
    await tester.tap(find.text('搜尋紀錄'));
    await tester.pumpAndSettle();

    expect(find.text('雞'), findsOneWidget);
    expect(find.text('高蛋白'), findsOneWidget);
  });

  testWidgets('redirects to login before opening protected features', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const MyApp());

    await tester.tap(find.text('查看推薦'));
    await tester.pumpAndSettle();

    expect(find.text('登入'), findsOneWidget);
    expect(find.text('測試登入'), findsOneWidget);
  });

  testWidgets('opens profile screen and logs in with demo account', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const MyApp());

    await tester.tap(find.text('我的'));
    await tester.pumpAndSettle();

    expect(find.text('登入'), findsOneWidget);
    expect(find.text('測試登入'), findsOneWidget);

    await tester.tap(find.text('測試登入'));
    await tester.pumpAndSettle();

    expect(find.text('測試使用者'), findsOneWidget);
    expect(find.text('飲食偏好'), findsOneWidget);
  });
}
