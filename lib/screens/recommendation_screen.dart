import 'package:flutter/material.dart';
import 'package:my_app/data/mock_food_repository.dart';
import 'package:my_app/models/food_item.dart';
import 'package:my_app/models/user_preference.dart';
import 'package:my_app/screens/food_detail_screen.dart';
import 'package:my_app/services/recommendation_service.dart';
import 'package:my_app/widgets/food_card.dart';

class RecommendationScreen extends StatefulWidget {
  const RecommendationScreen({super.key});

  @override
  State<RecommendationScreen> createState() => _RecommendationScreenState();
}

class _RecommendationScreenState extends State<RecommendationScreen> {
  final RecommendationService _recommendationService =
      const RecommendationService();
  final UserPreference _preference = UserPreference.defaultPreference;
  late List<FoodItem> recommendedFoods;

  @override
  void initState() {
    super.initState();
    recommendedFoods = _recommendationService.getRecommendations(
      foods: MockFoodRepository.allFoods,
      preference: _preference,
    );
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
          '推薦餐點',
          style: TextStyle(
            color: Color(0xFF2E3A2F),
            fontWeight: FontWeight.bold,
          ),
        ),
        iconTheme: const IconThemeData(color: Color(0xFF2E3A2F)),
      ),
      body: Column(
        children: [
          _buildTopSummary(),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 20),
              itemCount: recommendedFoods.length,
              itemBuilder: (context, index) {
                final food = recommendedFoods[index];
                return FoodCard(
                  food: food,
                  showDistance: true,
                  onTap: () => _goToFoodDetail(food),
                  onFavoritePressed: () => _toggleFavorite(index),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopSummary() {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF7DBA84), Color(0xFF4E8D57)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '今日推薦結果',
            style: TextStyle(color: Colors.white70, fontSize: 14),
          ),
          const SizedBox(height: 8),
          const Text(
            '依照你的偏好、預算與距離，\n幫你挑出最適合的餐點',
            style: TextStyle(
              color: Colors.white,
              fontSize: 21,
              fontWeight: FontWeight.bold,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            '推薦依據：${_preference.preferredTags.take(3).join(' / ')} / '
            '預算 ${_preference.budgetMin}-${_preference.budgetMax} 元 / '
            '距離 ${_preference.distanceLimitMeters ~/ 1000} 公里內',
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 13,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  void _goToFoodDetail(FoodItem food) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => FoodDetailScreen(food: food)),
    );
  }

  void _toggleFavorite(int index) {
    setState(() {
      final food = recommendedFoods[index];
      recommendedFoods[index] = food.copyWith(isFavorite: !food.isFavorite);
    });
  }
}
