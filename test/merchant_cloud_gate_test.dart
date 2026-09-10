import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:my_app/screens/merchant_login_screen.dart';
import 'package:my_app/screens/admin_product_screen.dart';
import 'package:my_app/services/merchant_auth_service.dart';
import 'package:my_app/services/member_api.dart';

void main() {
  testWidgets(
    'cloud entry points cannot expose demo merchant credentials or grant local privileges',
    (tester) async {
      SharedPreferences.setMockInitialValues({});
      FlutterSecureStorage.setMockInitialValues({});
      MerchantAuthService.instance.clearForTesting();
      expect(
        () => MerchantAuthService.instance.loginWithDemo(),
        throwsA(isA<MemberApiException>()),
      );
      await tester.pumpWidget(const MaterialApp(home: MerchantLoginScreen()));
      await tester.pumpAndSettle();
      expect(find.text('store@mcu-food.local'), findsNothing);
      expect(find.text('demo1234'), findsNothing);
      expect(find.text('登入商家後台'), findsOneWidget);
      await tester.pumpWidget(const MaterialApp(home: AdminProductScreen()));
      await tester.pumpAndSettle();
      expect(find.text('重新登入商家'), findsOneWidget);
      expect(find.text('建立上架草稿'), findsNothing);
    },
    skip: !const bool.fromEnvironment('CLOUD_CATALOG'),
  );
}
