import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:my_app/data/mock_food_repository.dart';
import 'package:my_app/models/food_item.dart';
import 'package:my_app/models/search_log.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserActivityService extends ChangeNotifier {
  UserActivityService._();

  static final UserActivityService instance = UserActivityService._();
  static const String _favoriteIdsKey = 'favorite_food_ids';
  static const String _historyIdsKey = 'history_food_ids';
  static const String _searchLogsKey = 'search_logs';

  SharedPreferences? _preferences;
  final Map<String, FoodItem> _favorites = {};
  final List<FoodItem> _history = [];
  final List<SearchLog> _searchLogs = [];

  List<FoodItem> get favorites => List.unmodifiable(_favorites.values);

  List<FoodItem> get history => List.unmodifiable(_history);

  List<SearchLog> get searchLogs => List.unmodifiable(_searchLogs);

  bool isFavorite(String foodId) {
    return _favorites.containsKey(foodId);
  }

  Future<void> initialize() async {
    try {
      _preferences = await SharedPreferences.getInstance();
    } on MissingPluginException {
      _preferences = null;
      return;
    }

    _restoreFavorites();
    _restoreHistory();
    _restoreSearchLogs();
  }

  void toggleFavorite(FoodItem food) {
    if (isFavorite(food.id)) {
      _favorites.remove(food.id);
    } else {
      _favorites[food.id] = food.copyWith(isFavorite: true);
    }

    _persistFavorites();
    notifyListeners();
  }

  void addHistory(FoodItem food) {
    _history.removeWhere((item) => item.id == food.id);
    _history.insert(0, food);

    if (_history.length > 20) {
      _history.removeRange(20, _history.length);
    }

    _persistHistory();
    notifyListeners();
  }

  void addSearchLog({required String keyword, required String filterSummary}) {
    final normalizedKeyword = keyword.trim();
    final normalizedSummary = filterSummary.trim();

    if (normalizedKeyword.isEmpty && normalizedSummary.isEmpty) {
      return;
    }

    _searchLogs.removeWhere(
      (log) =>
          log.keyword == normalizedKeyword &&
          log.filterSummary == normalizedSummary,
    );
    _searchLogs.insert(
      0,
      SearchLog(
        keyword: normalizedKeyword,
        filterSummary: normalizedSummary,
        searchedAt: DateTime.now(),
      ),
    );

    if (_searchLogs.length > 10) {
      _searchLogs.removeRange(10, _searchLogs.length);
    }

    _persistSearchLogs();
    notifyListeners();
  }

  void clearSearchLogs() {
    _searchLogs.clear();
    _persistSearchLogs();
    notifyListeners();
  }

  void _restoreFavorites() {
    final favoriteIds = _preferences?.getStringList(_favoriteIdsKey) ?? [];

    _favorites
      ..clear()
      ..addEntries(
        favoriteIds
            .map(_findFood)
            .whereType<FoodItem>()
            .map((food) => MapEntry(food.id, food.copyWith(isFavorite: true))),
      );
  }

  void _restoreHistory() {
    final historyIds = _preferences?.getStringList(_historyIdsKey) ?? [];

    _history
      ..clear()
      ..addAll(historyIds.map(_findFood).whereType<FoodItem>());
  }

  void _restoreSearchLogs() {
    final encodedLogs = _preferences?.getStringList(_searchLogsKey) ?? [];

    _searchLogs
      ..clear()
      ..addAll(
        encodedLogs
            .map(jsonDecode)
            .whereType<Map<String, Object?>>()
            .map(SearchLog.fromJson),
      );
  }

  FoodItem? _findFood(String foodId) {
    for (final food in MockFoodRepository.allFoods) {
      if (food.id == foodId) {
        return food;
      }
    }

    return null;
  }

  void _persistFavorites() {
    unawaited(
      _preferences?.setStringList(_favoriteIdsKey, _favorites.keys.toList()),
    );
  }

  void _persistHistory() {
    unawaited(
      _preferences?.setStringList(
        _historyIdsKey,
        _history.map((food) => food.id).toList(),
      ),
    );
  }

  void _persistSearchLogs() {
    unawaited(
      _preferences?.setStringList(
        _searchLogsKey,
        _searchLogs.map((log) => jsonEncode(log.toJson())).toList(),
      ),
    );
  }

  @visibleForTesting
  void clearForTesting() {
    _favorites.clear();
    _history.clear();
    _searchLogs.clear();
    unawaited(_preferences?.remove(_favoriteIdsKey));
    unawaited(_preferences?.remove(_historyIdsKey));
    unawaited(_preferences?.remove(_searchLogsKey));
    notifyListeners();
  }
}
