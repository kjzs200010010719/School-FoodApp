import 'package:flutter/foundation.dart';
import 'package:my_app/models/user_profile.dart';

class UserProfileService extends ChangeNotifier {
  UserProfileService._();

  static final UserProfileService instance = UserProfileService._();

  UserProfile? _profile;

  UserProfile? get profile => _profile;

  bool get isLoggedIn => _profile != null;

  void loginWithDemo() {
    _profile = UserProfile.demo;
    notifyListeners();
  }

  void updateProfile(UserProfile profile) {
    _profile = profile;
    notifyListeners();
  }

  void logout() {
    _profile = null;
    notifyListeners();
  }

  @visibleForTesting
  void clearForTesting() {
    _profile = null;
    notifyListeners();
  }
}
