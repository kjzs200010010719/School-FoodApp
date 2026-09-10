import 'package:my_app/services/request_id.dart';

class PendingCartLine {
  const PendingCartLine(this.foodId, this.quantity);
  final String foodId;
  final int quantity;
  Map<String, Object?> toJson() => {'foodId': foodId, 'quantity': quantity};
}

class PendingCheckout {
  const PendingCheckout(this.id, this.items);
  final String id;
  final List<PendingCartLine> items;

  factory PendingCheckout.create(List<PendingCartLine> items) {
    return PendingCheckout(newRequestId(), List.unmodifiable(items));
  }
  factory PendingCheckout.fromJson(Map<String, dynamic> json) {
    final id = json['id'];
    final rows = json['items'];
    if (id is! String ||
        !RegExp(
          r'^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$',
        ).hasMatch(id) ||
        rows is! List ||
        rows.isEmpty ||
        rows.length > 50) {
      throw const FormatException();
    }
    final items = rows.map((row) {
      if (row is! Map<String, dynamic>) throw const FormatException();
      final foodId = row['foodId'];
      final quantity = row['quantity'];
      if (foodId is! String ||
          !RegExp(r'^[1-9][0-9]{0,19}$').hasMatch(foodId) ||
          quantity is! int ||
          quantity < 1 ||
          quantity > 99) {
        throw const FormatException();
      }
      return PendingCartLine(foodId, quantity);
    }).toList();
    if (items.map((item) => item.foodId).toSet().length != items.length) {
      throw const FormatException();
    }
    return PendingCheckout(id, List.unmodifiable(items));
  }
  Map<String, Object?> toJson() => {
    'id': id,
    'items': items.map((item) => item.toJson()).toList(),
  };
}
