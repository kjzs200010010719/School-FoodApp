import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:my_app/data/mock_food_repository.dart';
import 'package:my_app/models/cart_item.dart';
import 'package:my_app/models/food_item.dart';
import 'package:my_app/models/purchase_record.dart';
import 'package:my_app/models/search_log.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserActivityService extends ChangeNotifier {
  UserActivityService._();

  static final UserActivityService instance = UserActivityService._();
  static const String _favoriteIdsKey = 'favorite_food_ids';
  static const String _historyIdsKey = 'history_food_ids';
  static const String _searchLogsKey = 'search_logs';
  static const String _cartItemsKey = 'cart_items';
  static const String _purchaseRecordsKey = 'purchase_records';

  SharedPreferences? _preferences;
  final Map<String, FoodItem> _favorites = {};
  final List<FoodItem> _history = [];
  final List<SearchLog> _searchLogs = [];
  final Map<String, int> _cartQuantities = {};
  final List<PurchaseRecord> _purchaseRecords = [];

  List<FoodItem> get favorites => List.unmodifiable(_favorites.values);

  List<FoodItem> get history => List.unmodifiable(_history);

  List<SearchLog> get searchLogs => List.unmodifiable(_searchLogs);

  List<CartItem> get cartItems {
    final items = <CartItem>[];

    for (final entry in _cartQuantities.entries) {
      final food = _findFood(entry.key);
      if (food != null && entry.value > 0) {
        items.add(CartItem(food: food, quantity: entry.value));
      }
    }

    return List.unmodifiable(items);
  }

  List<PurchaseRecord> get purchaseRecords {
    return List.unmodifiable(_purchaseRecords);
  }

  int get cartTotalQuantity {
    return cartItems.fold(0, (sum, item) => sum + item.quantity);
  }

  int get cartTotalPrice {
    return cartItems.fold(0, (sum, item) => sum + item.subtotal);
  }

  bool isFavorite(String foodId) {
    return _favorites.containsKey(foodId);
  }

  bool isInCart(String foodId) {
    return (_cartQuantities[foodId] ?? 0) > 0;
  }

  int cartQuantity(String foodId) {
    return _cartQuantities[foodId] ?? 0;
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
    _restoreCartItems();
    _restorePurchaseRecords();
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

  void addToCart(FoodItem food) {
    setCartQuantity(food, cartQuantity(food.id) + 1);
  }

  void increaseCartItem(FoodItem food) {
    addToCart(food);
  }

  void decreaseCartItem(FoodItem food) {
    setCartQuantity(food, cartQuantity(food.id) - 1);
  }

  void setCartQuantity(FoodItem food, int quantity) {
    final nextQuantity = quantity.clamp(0, food.stockCount).toInt();

    if (nextQuantity == 0) {
      _cartQuantities.remove(food.id);
    } else {
      _cartQuantities[food.id] = nextQuantity;
    }

    _persistCartItems();
    notifyListeners();
  }

  PurchaseRecord? checkoutCart() {
    final items = cartItems;

    if (items.isEmpty) {
      return null;
    }

    final record = PurchaseRecord(
      id: 'purchase-${DateTime.now().microsecondsSinceEpoch}',
      purchasedAt: DateTime.now(),
      items: items,
    );

    _purchaseRecords.insert(0, record);
    if (_purchaseRecords.length > 20) {
      _purchaseRecords.removeRange(20, _purchaseRecords.length);
    }

    _cartQuantities.clear();
    _persistCartItems();
    _persistPurchaseRecords();
    notifyListeners();
    return record;
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

  void _restoreCartItems() {
    final encodedItems = _preferences?.getStringList(_cartItemsKey) ?? [];

    _cartQuantities.clear();
    for (final encodedItem in encodedItems) {
      final parts = encodedItem.split(':');
      if (parts.length != 2) {
        continue;
      }

      final food = _findFood(parts.first);
      final quantity = int.tryParse(parts.last);
      if (food != null && quantity != null && quantity > 0) {
        _cartQuantities[food.id] = quantity.clamp(1, food.stockCount).toInt();
      }
    }
  }

  void _restorePurchaseRecords() {
    final encodedRecords =
        _preferences?.getStringList(_purchaseRecordsKey) ?? [];

    _purchaseRecords
      ..clear()
      ..addAll(
        encodedRecords.map(_decodePurchaseRecord).whereType<PurchaseRecord>(),
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

  void _persistCartItems() {
    unawaited(
      _preferences?.setStringList(
        _cartItemsKey,
        _cartQuantities.entries
            .map((entry) => '${entry.key}:${entry.value}')
            .toList(),
      ),
    );
  }

  void _persistPurchaseRecords() {
    unawaited(
      _preferences?.setStringList(
        _purchaseRecordsKey,
        _purchaseRecords.map(_encodePurchaseRecord).toList(),
      ),
    );
  }

  String _encodePurchaseRecord(PurchaseRecord record) {
    return jsonEncode({
      'id': record.id,
      'purchasedAt': record.purchasedAt.toIso8601String(),
      'items': record.items
          .map((item) => {'foodId': item.food.id, 'quantity': item.quantity})
          .toList(),
    });
  }

  PurchaseRecord? _decodePurchaseRecord(String encodedRecord) {
    try {
      final decoded = jsonDecode(encodedRecord);
      if (decoded is! Map<String, dynamic>) {
        return null;
      }

      final id = decoded['id'] as String?;
      final purchasedAtText = decoded['purchasedAt'] as String?;
      final itemMaps = decoded['items'] as List?;

      if (id == null || purchasedAtText == null || itemMaps == null) {
        return null;
      }

      final items = <CartItem>[];
      for (final itemMap in itemMaps) {
        if (itemMap is! Map<String, dynamic>) {
          continue;
        }

        final foodId = itemMap['foodId'] as String?;
        final quantity = itemMap['quantity'] as int?;
        final food = foodId == null ? null : _findFood(foodId);
        if (food != null && quantity != null && quantity > 0) {
          items.add(CartItem(food: food, quantity: quantity));
        }
      }

      if (items.isEmpty) {
        return null;
      }

      return PurchaseRecord(
        id: id,
        purchasedAt: DateTime.parse(purchasedAtText),
        items: items,
      );
    } on FormatException {
      return null;
    } on TypeError {
      return null;
    }
  }

  @visibleForTesting
  void clearForTesting() {
    _favorites.clear();
    _history.clear();
    _searchLogs.clear();
    _cartQuantities.clear();
    _purchaseRecords.clear();
    unawaited(_preferences?.remove(_favoriteIdsKey));
    unawaited(_preferences?.remove(_historyIdsKey));
    unawaited(_preferences?.remove(_searchLogsKey));
    unawaited(_preferences?.remove(_cartItemsKey));
    unawaited(_preferences?.remove(_purchaseRecordsKey));
    notifyListeners();
  }
}
