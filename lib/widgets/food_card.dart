import 'package:flutter/material.dart';
import 'package:my_app/models/food_item.dart';
import 'package:my_app/widgets/food_info_tag.dart';

enum FoodCardVariant { recommendation, expiring }

class FoodCard extends StatelessWidget {
  const FoodCard({
    super.key,
    required this.food,
    this.variant = FoodCardVariant.recommendation,
    this.onTap,
    this.onFavoritePressed,
    this.showDistance = false,
    this.isFavorite,
  });

  final FoodItem food;
  final FoodCardVariant variant;
  final VoidCallback? onTap;
  final VoidCallback? onFavoritePressed;
  final bool showDistance;
  final bool? isFavorite;

  bool get _isExpiring => variant == FoodCardVariant.expiring;

  @override
  Widget build(BuildContext context) {
    final card = Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _isExpiring ? const Color(0xFFFFFBF2) : Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: _isExpiring ? Border.all(color: const Color(0xFFFFE3A3)) : null,
        boxShadow: _isExpiring
            ? null
            : [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildIconBox(),
          const SizedBox(width: 14),
          Expanded(child: _buildContent()),
          _buildActionButton(),
        ],
      ),
    );

    if (onTap == null) {
      return card;
    }

    return GestureDetector(onTap: onTap, child: card);
  }

  Widget _buildIconBox() {
    return Container(
      width: 72,
      height: 72,
      decoration: BoxDecoration(
        color: _isExpiring ? const Color(0xFFFFF1CC) : const Color(0xFFEAF5E8),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Icon(
        food.icon,
        size: 34,
        color: _isExpiring ? const Color(0xFFD68A00) : const Color(0xFF4E8D57),
      ),
    );
  }

  Widget _buildContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          food.name,
          style: const TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.bold,
            color: Color(0xFF2E3A2F),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          food.storeName,
          style: const TextStyle(fontSize: 13, color: Colors.black54),
        ),
        const SizedBox(height: 8),
        Wrap(spacing: 8, runSpacing: 8, children: _buildTags()),
        if (!_isExpiring) ...[
          const SizedBox(height: 8),
          Text(
            food.recommendationReason,
            style: const TextStyle(
              fontSize: 13,
              color: Color(0xFF4E8D57),
              fontWeight: FontWeight.w500,
              height: 1.4,
            ),
          ),
        ],
      ],
    );
  }

  List<Widget> _buildTags() {
    if (_isExpiring) {
      return [
        if (food.discountLabel != null)
          FoodInfoTag(text: food.discountLabel!, warning: true),
        FoodInfoTag(text: food.timeLeftLabel, warning: true),
        FoodInfoTag(text: food.priceLabel, warning: true),
      ];
    }

    return [
      FoodInfoTag(text: food.tags.first),
      FoodInfoTag(text: food.priceLabel),
      if (showDistance) FoodInfoTag(text: food.distanceLabel),
    ];
  }

  Widget _buildActionButton() {
    final favorite = isFavorite ?? food.isFavorite;

    if (_isExpiring) {
      return IconButton(
        onPressed: onFavoritePressed,
        icon: Icon(
          favorite ? Icons.bookmark_rounded : Icons.bookmark_border_rounded,
          color: favorite ? const Color(0xFFD68A00) : null,
        ),
      );
    }

    return IconButton(
      onPressed: onFavoritePressed,
      icon: Icon(
        favorite ? Icons.favorite_rounded : Icons.favorite_border_rounded,
        color: Colors.redAccent,
      ),
    );
  }
}
