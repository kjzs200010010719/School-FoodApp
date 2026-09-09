import 'package:flutter_test/flutter_test.dart';
import 'package:my_app/models/merchant_account.dart';
import 'package:my_app/services/merchant_auth_service.dart';

void main() {
  final service = MerchantAuthService.instance;

  setUp(service.clearForTesting);

  test('logs in with demo merchant account', () {
    service.loginWithDemo(email: 'owner@example.com');

    expect(service.isLoggedIn, isTrue);
    expect(service.account?.businessName, '銘傳校園示範商家');
    expect(service.account?.email, 'owner@example.com');
    expect(service.account?.primaryStoreName, '全家龜山銘美店');
    expect(
      service.account?.allowedStoreNames,
      MerchantAccount.demo.allowedStoreNames,
    );
  });

  test('logs out merchant account', () {
    service.loginWithDemo();

    service.logout();

    expect(service.isLoggedIn, isFalse);
    expect(service.account, isNull);
  });
}
