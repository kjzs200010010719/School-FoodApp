import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:my_app/data/food_catalog_repository.dart';
import 'package:my_app/screens/home_screen.dart';
import 'package:my_app/services/user_activity_service.dart';

void main() {
  testWidgets(
    'cloud mode shows an empty home without demo foods and blocks local checkout',
    (tester) async {
      tester.view.physicalSize = const Size(320, 640);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      expect(FoodCatalogRepository.instance.allFoods, isEmpty);
      expect(UserActivityService.instance.canCheckout, false);
      expect(UserActivityService.instance.checkoutCart(), isNull);
      await tester.pumpWidget(const MaterialApp(home: HomeScreen()));
      await tester.pumpAndSettle();
      expect(find.text('目前沒有上架餐點'), findsOneWidget);
      expect(find.byTooltip('更新商品'), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
    skip: !FoodCatalogRepository.instance.useCloud,
  );
}
