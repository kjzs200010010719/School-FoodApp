import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:my_app/data/mock_food_repository.dart';
import 'package:my_app/main.dart';
import 'package:my_app/services/user_activity_service.dart';
import 'package:my_app/services/user_profile_service.dart';
import 'package:my_app/widgets/food_card.dart';

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

    await tester.tap(find.byType(FoodCard).first);
    await tester.pumpAndSettle();

    expect(find.text('餐點資訊'), findsOneWidget);
    expect(find.text('推薦原因'), findsOneWidget);
  });

  testWidgets('opens convenience expiring store and product list', (
    WidgetTester tester,
  ) async {
    UserProfileService.instance.loginWithDemo();
    await tester.pumpWidget(const MyApp());

    await tester.scrollUntilVisible(
      find.text('鮪魚御飯糰'),
      200,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.tap(find.text('鮪魚御飯糰'));
    await tester.pumpAndSettle();

    expect(find.text('依距離上限 1000 公尺'), findsOneWidget);
    expect(find.textContaining('模擬位置：桃園銘傳大學'), findsOneWidget);
    expect(find.text('全家'), findsWidgets);
    expect(find.text('7-11'), findsWidgets);

    await tester.tap(find.text('全家').first);
    await tester.pumpAndSettle();
    await tester.tap(find.text('全家龜山銘美店'));
    await tester.pumpAndSettle();

    expect(find.text('門市即期商品'), findsOneWidget);
    expect(find.text('明太子鮭魚飯糰'), findsOneWidget);
  });

  testWidgets('opens cart from home and checks out', (
    WidgetTester tester,
  ) async {
    UserProfileService.instance.loginWithDemo();
    final service = UserActivityService.instance;
    service.addToCart(MockFoodRepository.allFoods.first);

    await tester.pumpWidget(const MyApp());

    await tester.tap(find.byIcon(Icons.shopping_cart_outlined));
    await tester.pumpAndSettle();

    expect(find.text('購物車'), findsOneWidget);
    expect(find.text('結帳'), findsOneWidget);

    await tester.tap(find.text('結帳'));
    await tester.pumpAndSettle();

    expect(find.text('膳解人意'), findsOneWidget);
    expect(service.cartItems, isEmpty);
    expect(service.purchaseRecords, hasLength(1));
  });

  testWidgets('opens search screen after submitting home search', (
    WidgetTester tester,
  ) async {
    UserProfileService.instance.loginWithDemo();
    await tester.pumpWidget(const MyApp());

    await tester.enterText(find.byType(TextField).first, '雞胸');
    await tester.tap(find.byIcon(Icons.arrow_forward_rounded));
    await tester.pumpAndSettle();

    expect(find.text('搜尋餐點'), findsOneWidget);
    expect(find.text('餐點、店家、食材或標籤'), findsOneWidget);
    expect(find.textContaining('舒肥雞胸餐盒'), findsWidgets);
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
      keyword: '雞胸',
      filterSummary: '高蛋白',
    );
    await tester.pumpWidget(const MyApp());

    await tester.tap(find.text('收藏').last);
    await tester.pumpAndSettle();
    await tester.tap(find.text('搜尋紀錄'));
    await tester.pumpAndSettle();

    expect(find.text('雞胸'), findsOneWidget);
    expect(find.text('高蛋白'), findsOneWidget);
  });

  testWidgets('opens search from search log and clears logs', (
    WidgetTester tester,
  ) async {
    UserProfileService.instance.loginWithDemo();
    UserActivityService.instance.addSearchLog(
      keyword: '雞胸',
      filterSummary: '高蛋白',
    );
    await tester.pumpWidget(const MyApp());

    await tester.tap(find.text('收藏').last);
    await tester.pumpAndSettle();
    await tester.tap(find.text('搜尋紀錄'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('雞胸'));
    await tester.pumpAndSettle();

    expect(find.text('搜尋餐點'), findsOneWidget);
    expect(find.textContaining('舒肥雞胸餐盒'), findsWidgets);

    await tester.pageBack();
    await tester.pumpAndSettle();
    await tester.tap(find.text('清除'));
    await tester.pumpAndSettle();

    expect(find.text('尚無搜尋紀錄'), findsOneWidget);
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

  testWidgets('logs in with demo account and returns home', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const MyApp());

    await tester.tap(find.text('我的'));
    await tester.pumpAndSettle();

    expect(find.text('登入'), findsOneWidget);
    expect(find.text('測試登入'), findsOneWidget);

    await tester.tap(find.text('測試登入'));
    await tester.pumpAndSettle();

    expect(find.text('膳解人意'), findsOneWidget);
    expect(find.text('今日推薦'), findsOneWidget);
    expect(UserProfileService.instance.isLoggedIn, isTrue);
  });

  testWidgets('opens collection tabs from profile stats', (
    WidgetTester tester,
  ) async {
    UserProfileService.instance.loginWithDemo();
    await tester.pumpWidget(const MyApp());

    await tester.tap(find.text('我的'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('收藏').first);
    await tester.pumpAndSettle();

    expect(find.text('收藏與紀錄'), findsOneWidget);
    expect(find.text('尚未收藏餐點'), findsOneWidget);

    await tester.tap(find.text('我的'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('瀏覽紀錄').first);
    await tester.pumpAndSettle();

    expect(find.text('收藏與紀錄'), findsOneWidget);
    expect(find.text('尚無瀏覽紀錄'), findsOneWidget);
  });

  testWidgets('opens purchase records from profile order stat', (
    WidgetTester tester,
  ) async {
    UserProfileService.instance.loginWithDemo();
    final service = UserActivityService.instance;
    final food = MockFoodRepository.expiringFoods.first;
    service.addToCart(food);
    service.checkoutCart();

    await tester.pumpWidget(const MyApp());

    await tester.tap(find.text('我的'));
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(
      find.text('今日健康摘要'),
      200,
      scrollable: find.byType(Scrollable).first,
    );

    expect(find.text('今日健康摘要'), findsOneWidget);
    expect(find.text(food.caloriesLabel), findsOneWidget);

    await tester.scrollUntilVisible(
      find.text('減廢成就'),
      200,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pumpAndSettle();

    expect(find.text('減廢成就'), findsOneWidget);
    expect(find.text('惜食點數'), findsOneWidget);
    expect(find.text('即期份數'), findsOneWidget);

    await tester.drag(find.byType(ListView).first, const Offset(0, 900));
    await tester.pumpAndSettle();

    await tester.tap(find.text('點餐紀錄'));
    await tester.pumpAndSettle();

    expect(find.text('收藏與紀錄'), findsOneWidget);
    expect(find.text('購買紀錄'), findsWidgets);
  });
}
