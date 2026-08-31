import 'package:my_app/models/cart_item.dart';

class PurchaseRecord {
  const PurchaseRecord({
    required this.id,
    required this.purchasedAt,
    required this.items,
  });

  final String id;
  final DateTime purchasedAt;
  final List<CartItem> items;

  int get totalQuantity {
    return items.fold(0, (sum, item) => sum + item.quantity);
  }

  int get totalPrice {
    return items.fold(0, (sum, item) => sum + item.subtotal);
  }

  String get purchasedAtLabel {
    final month = purchasedAt.month.toString().padLeft(2, '0');
    final day = purchasedAt.day.toString().padLeft(2, '0');
    final hour = purchasedAt.hour.toString().padLeft(2, '0');
    final minute = purchasedAt.minute.toString().padLeft(2, '0');
    return '$month/$day $hour:$minute';
  }

  String get summaryLabel => '$totalQuantity 項 / NT\$ $totalPrice';
}
