import 'package:flutter/foundation.dart';
import 'package:my_app/models/food_item.dart';

class UserActivityService extends ChangeNotifier {
  UserActivityService._();

  static final UserActivityService instance = UserActivityService._();

  final Map<String, FoodItem> _favorites = {};
  final List<FoodItem> _history = [];

  List<FoodItem> get favorites => List.unmodifiable(_favorites.values);

  List<FoodItem> get history => List.unmodifiable(_history);

  bool isFavorite(String foodId) {
    return _favorites.containsKey(foodId);
  }

  void toggleFavorite(FoodItem food) {
    if (isFavorite(food.id)) {
      _favorites.remove(food.id);
    } else {
      _favorites[food.id] = food.copyWith(isFavorite: true);
    }

    notifyListeners();
  }

  void addHistory(FoodItem food) {
    _history.removeWhere((item) => item.id == food.id);
    _history.insert(0, food);

    if (_history.length > 20) {
      _history.removeRange(20, _history.length);
    }

    notifyListeners();
  }

  @visibleForTesting
  void clearForTesting() {
    _favorites.clear();
    _history.clear();
    notifyListeners();
  }
}
