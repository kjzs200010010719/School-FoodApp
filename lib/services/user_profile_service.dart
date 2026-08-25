import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:my_app/models/user_profile.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserProfileService extends ChangeNotifier {
  UserProfileService._();

  static final UserProfileService instance = UserProfileService._();
  static const String _profileKey = 'user_profile';

  SharedPreferences? _preferences;
  UserProfile? _profile;

  UserProfile? get profile => _profile;

  bool get isLoggedIn => _profile != null;

  Future<void> initialize() async {
    try {
      _preferences = await SharedPreferences.getInstance();
    } on MissingPluginException {
      _preferences = null;
      return;
    }

    final profileJson = _preferences?.getString(_profileKey);

    if (profileJson == null) {
      return;
    }

    final decoded = jsonDecode(profileJson);
    if (decoded is Map<String, Object?>) {
      _profile = UserProfile.fromJson(decoded);
    }
  }

  void loginWithDemo() {
    _profile = UserProfile.demo;
    _persistProfile();
    notifyListeners();
  }

  void updateProfile(UserProfile profile) {
    _profile = profile;
    _persistProfile();
    notifyListeners();
  }

  void logout() {
    _profile = null;
    unawaited(_preferences?.remove(_profileKey));
    notifyListeners();
  }

  void _persistProfile() {
    final profile = _profile;
    if (profile == null) {
      return;
    }

    unawaited(
      _preferences?.setString(_profileKey, jsonEncode(profile.toJson())),
    );
  }

  @visibleForTesting
  void clearForTesting() {
    _profile = null;
    unawaited(_preferences?.remove(_profileKey));
    notifyListeners();
  }
}
