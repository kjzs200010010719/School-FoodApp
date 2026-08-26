import 'package:flutter/material.dart';
import 'package:my_app/models/food_item.dart';
import 'package:my_app/services/user_activity_service.dart';
import 'package:my_app/widgets/food_info_tag.dart';

class FoodDetailScreen extends StatefulWidget {
  const FoodDetailScreen({super.key, required this.food});

  final FoodItem food;

  @override
  State<FoodDetailScreen> createState() => _FoodDetailScreenState();
}

class _FoodDetailScreenState extends State<FoodDetailScreen> {
  final UserActivityService _activityService = UserActivityService.instance;

  FoodItem get food => widget.food;

  @override
  void initState() {
    super.initState();
    _activityService.addListener(_refresh);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _activityService.addHistory(food);
    });
  }

  @override
  void dispose() {
    _activityService.removeListener(_refresh);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F9F4),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF7F9F4),
        elevation: 0,
        centerTitle: true,
        title: const Text(
          '餐點詳情',
          style: TextStyle(
            color: Color(0xFF2E3A2F),
            fontWeight: FontWeight.bold,
          ),
        ),
        iconTheme: const IconThemeData(color: Color(0xFF2E3A2F)),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
          children: [
            _buildHero(),
            const SizedBox(height: 16),
            _buildRecommendationReason(),
            const SizedBox(height: 16),
            _buildInfoGrid(),
            const SizedBox(height: 16),
            _buildTagSection('食材資訊', food.ingredients),
            const SizedBox(height: 16),
            _buildTagSection('營養與偏好標籤', food.nutritionTags + food.tags),
            const SizedBox(height: 16),
            _buildStoreInfo(),
            const SizedBox(height: 20),
            _buildActionButton(context),
          ],
        ),
      ),
    );
  }

  Widget _buildHero() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
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
          Container(
            width: 76,
            height: 76,
            decoration: BoxDecoration(
              color: food.isExpiringSoon
                  ? const Color(0xFFFFF1CC)
                  : const Color(0xFFEAF5E8),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Icon(
              food.icon,
              size: 38,
              color: food.isExpiringSoon
                  ? const Color(0xFFD68A00)
                  : const Color(0xFF4E8D57),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  food.name,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2E3A2F),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  food.storeName,
                  style: const TextStyle(fontSize: 14, color: Colors.black54),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    FoodInfoTag(text: food.category),
                    FoodInfoTag(text: food.priceLabel),
                    if (food.discountLabel != null)
                      FoodInfoTag(text: food.discountLabel!, warning: true),
                    if (food.isExpiringSoon)
                      FoodInfoTag(text: food.timeLeftLabel, warning: true),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecommendationReason() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFFEAF5E8),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.auto_awesome_rounded, color: Color(0xFF4E8D57)),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '推薦原因',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2E3A2F),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  food.recommendationReason,
                  style: const TextStyle(
                    fontSize: 14,
                    height: 1.5,
                    color: Color(0xFF4E8D57),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoGrid() {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      childAspectRatio: 1.45,
      children: [
        _buildInfoTile(Icons.payments_rounded, '價格', _priceDetail),
        _buildInfoTile(Icons.place_rounded, '距離', food.distanceLabel),
        _buildInfoTile(Icons.inventory_2_rounded, '庫存', '${food.stockCount} 份'),
        _buildInfoTile(
          Icons.eco_rounded,
          '減廢分數',
          '${(food.ecoPriorityScore * 100).round()} 分',
        ),
      ],
    );
  }

  String get _priceDetail {
    if (food.originalPrice == null) {
      return food.priceLabel;
    }

    return '${food.priceLabel} / 原價 NT\$ ${food.originalPrice}';
  }

  Widget _buildInfoTile(IconData icon, String title, String value) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: const Color(0xFF4E8D57), size: 22),
          const SizedBox(height: 8),
          Text(
            title,
            style: const TextStyle(fontSize: 12, color: Colors.black54),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Color(0xFF2E3A2F),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTagSection(String title, List<String> values) {
    return _buildSection(
      title: title,
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: values
            .toSet()
            .map((value) => FoodInfoTag(text: value))
            .toList(),
      ),
    );
  }

  Widget _buildStoreInfo() {
    return _buildSection(
      title: '店家資訊',
      child: Column(
        children: [
          _buildStoreRow(Icons.storefront_rounded, food.storeName),
          _buildStoreRow(Icons.location_on_rounded, food.storeAddress),
          _buildStoreRow(Icons.schedule_rounded, food.businessScheduleLabel),
          _buildStoreRow(Icons.call_rounded, food.contactPhone),
        ],
      ),
    );
  }

  Widget _buildSection({required String title, required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.bold,
              color: Color(0xFF2E3A2F),
            ),
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }

  Widget _buildStoreRow(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: const Color(0xFF4E8D57)),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(fontSize: 14, color: Color(0xFF2E3A2F)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(BuildContext context) {
    final isFavorite = _activityService.isFavorite(food.id);

    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: () {
          _activityService.toggleFavorite(food);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                isFavorite ? '已將 ${food.name} 移出收藏' : '已將 ${food.name} 加入收藏',
              ),
              duration: const Duration(seconds: 1),
            ),
          );
        },
        icon: Icon(
          isFavorite ? Icons.favorite_rounded : Icons.favorite_border_rounded,
        ),
        label: Text(isFavorite ? '取消收藏' : '加入收藏'),
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF4E8D57),
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 15),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
    );
  }

  void _refresh() {
    if (mounted) {
      setState(() {});
    }
  }
}
