import 'package:flutter/material.dart';
import 'package:my_app/models/cart_item.dart';
import 'package:my_app/services/user_activity_service.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key, this.onCheckoutComplete});

  final VoidCallback? onCheckoutComplete;

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  final UserActivityService _activityService = UserActivityService.instance;

  @override
  void initState() {
    super.initState();
    _activityService.addListener(_refresh);
  }

  @override
  void dispose() {
    _activityService.removeListener(_refresh);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cartItems = _activityService.cartItems;

    return Scaffold(
      backgroundColor: const Color(0xFFF7F9F4),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF7F9F4),
        elevation: 0,
        centerTitle: true,
        title: const Text(
          '購物車',
          style: TextStyle(
            color: Color(0xFF2E3A2F),
            fontWeight: FontWeight.bold,
          ),
        ),
        iconTheme: const IconThemeData(color: Color(0xFF2E3A2F)),
      ),
      body: SafeArea(
        child: cartItems.isEmpty
            ? _buildEmptyState()
            : Column(
                children: [
                  Expanded(child: _buildCartList(cartItems)),
                  _buildCheckoutPanel(),
                ],
              ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 78,
              height: 78,
              decoration: const BoxDecoration(
                color: Color(0xFFEAF5E8),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.shopping_cart_outlined,
                color: Color(0xFF4E8D57),
                size: 38,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              '購物車是空的',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF2E3A2F),
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              '到餐點資訊頁加入想購買的商品，就能在這裡調整數量與結帳。',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.black54, height: 1.5),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCartList(List<CartItem> cartItems) {
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      itemCount: cartItems.length,
      itemBuilder: (context, index) => _buildCartTile(cartItems[index]),
    );
  }

  Widget _buildCartTile(CartItem item) {
    final food = item.food;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 58,
            height: 58,
            decoration: BoxDecoration(
              color: food.isExpiringSoon
                  ? const Color(0xFFFFF1CC)
                  : const Color(0xFFEAF5E8),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(
              food.icon,
              color: food.isExpiringSoon
                  ? const Color(0xFFD68A00)
                  : const Color(0xFF4E8D57),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  food.name,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2E3A2F),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${food.storeName} / ${food.priceLabel}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 13, color: Colors.black54),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          _buildQuantityControl(item),
        ],
      ),
    );
  }

  Widget _buildQuantityControl(CartItem item) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton.filledTonal(
          visualDensity: VisualDensity.compact,
          onPressed: () => _activityService.decreaseCartItem(item.food),
          icon: const Icon(Icons.remove_rounded),
        ),
        SizedBox(
          width: 28,
          child: Text(
            '${item.quantity}',
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Color(0xFF2E3A2F),
            ),
          ),
        ),
        IconButton.filledTonal(
          visualDensity: VisualDensity.compact,
          onPressed: item.quantity >= item.food.stockCount
              ? null
              : () => _activityService.increaseCartItem(item.food),
          icon: const Icon(Icons.add_rounded),
        ),
      ],
    );
  }

  Widget _buildCheckoutPanel() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Color(0xFFE5EDE2))),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              const Expanded(
                child: Text('商品數量', style: TextStyle(color: Colors.black54)),
              ),
              Text(
                '${_activityService.cartTotalQuantity} 項',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2E3A2F),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Expanded(
                child: Text('總金額', style: TextStyle(color: Colors.black54)),
              ),
              Text(
                'NT\$ ${_activityService.cartTotalPrice}',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2E3A2F),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: _checkout,
              icon: const Icon(Icons.check_circle_rounded),
              label: const Text('結帳'),
            ),
          ),
        ],
      ),
    );
  }

  void _checkout() {
    final record = _activityService.checkoutCart();
    if (record == null) {
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          '購買成功，共 ${record.totalQuantity} 項，NT\$ ${record.totalPrice}',
        ),
        duration: const Duration(seconds: 1),
      ),
    );

    widget.onCheckoutComplete?.call();
    Navigator.of(context).popUntil((route) => route.isFirst);
  }

  void _refresh() {
    if (mounted) {
      setState(() {});
    }
  }
}
