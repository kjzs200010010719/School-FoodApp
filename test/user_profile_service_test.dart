import 'package:flutter_test/flutter_test.dart';
import 'package:my_app/models/user_profile.dart';
import 'package:my_app/services/user_profile_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  final service = UserProfileService.instance;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await service.initialize();
    service.clearForTesting();
  });

  test('logs in with demo profile and logs out', () {
    service.loginWithDemo();

    expect(service.isLoggedIn, isTrue);
    expect(service.profile?.name, '測試使用者');

    service.logout();

    expect(service.isLoggedIn, isFalse);
    expect(service.profile, isNull);
  });

  test('updates local profile preferences', () {
    service.loginWithDemo();

    service.updateProfile(
      UserProfile.demo.copyWith(
        name: '王小明',
        dietaryTags: ['低脂'],
        budgetMax: 120,
      ),
    );

    expect(service.profile?.name, '王小明');
    expect(service.profile?.dietaryTags, ['低脂']);
    expect(service.profile?.budgetMax, 120);
  });

  test('restores saved profile from local storage', () async {
    service.updateProfile(
      UserProfile.demo.copyWith(
        name: '陳小美',
        dietaryTags: ['素食', '高纖'],
        clearBudgetMax: true,
      ),
    );

    await service.initialize();

    expect(service.isLoggedIn, isTrue);
    expect(service.profile?.name, '陳小美');
    expect(service.profile?.dietaryTags, ['素食', '高纖']);
    expect(service.profile?.budgetMax, isNull);
  });
}
