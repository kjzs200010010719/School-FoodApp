import 'package:flutter/foundation.dart';
import 'package:my_app/models/merchant_account.dart';

class MerchantAuthService extends ChangeNotifier {
  MerchantAuthService._();

  static final MerchantAuthService instance = MerchantAuthService._();

  MerchantAccount? _account;

  MerchantAccount? get account => _account;

  bool get isLoggedIn => _account != null;

  void loginWithDemo({String? email}) {
    final normalizedEmail = email?.trim();
    _account = MerchantAccount.demo.copyWith(
      email: normalizedEmail == null || normalizedEmail.isEmpty
          ? MerchantAccount.demo.email
          : normalizedEmail,
    );
    notifyListeners();
  }

  void logout() {
    _account = null;
    notifyListeners();
  }

  @visibleForTesting
  void clearForTesting() {
    _account = null;
    notifyListeners();
  }
}
