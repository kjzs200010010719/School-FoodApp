import 'package:my_app/models/food_item.dart';

class CartItem {
  const CartItem({required this.food, required this.quantity});

  final FoodItem food;
  final int quantity;

  int get subtotal => food.price * quantity;
}
