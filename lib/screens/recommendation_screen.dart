import 'package:flutter/material.dart';
import 'package:my_app/data/mock_food_repository.dart';
import 'package:my_app/models/food_item.dart';
import 'package:my_app/models/user_preference.dart';
import 'package:my_app/screens/food_detail_screen.dart';
import 'package:my_app/services/recommendation_service.dart';
import 'package:my_app/services/user_activity_service.dart';
import 'package:my_app/services/user_profile_service.dart';
import 'package:my_app/widgets/food_card.dart';

class RecommendationScreen extends StatefulWidget {
  const RecommendationScreen({super.key, this.showAppBar = true});

  final bool showAppBar;

  @override
  State<RecommendationScreen> createState() => _RecommendationScreenState();
}

class _RecommendationScreenState extends State<RecommendationScreen> {
  final RecommendationService _recommendationService =
      const RecommendationService();
  final UserActivityService _activityService = UserActivityService.instance;
  final UserProfileService _profileService = UserProfileService.instance;
  late List<FoodItem> recommendedFoods;

  @override
  void initState() {
    super.initState();
    recommendedFoods = _buildRecommendations();
    _activityService.addListener(_refresh);
    _profileService.addListener(_refreshRecommendations);
  }

  @override
  void dispose() {
    _activityService.removeListener(_refresh);
    _profileService.removeListener(_refreshRecommendations);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F9F4),
      appBar: widget.showAppBar
          ? AppBar(
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
            )
          : null,
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
                  isFavorite: _activityService.isFavorite(food.id),
                  onTap: () => _goToFoodDetail(food),
                  onFavoritePressed: () =>
                      _activityService.toggleFavorite(food),
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
            _summaryText,
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

  List<FoodItem> _buildRecommendations() {
    return _recommendationService.getRecommendations(
      foods: MockFoodRepository.allFoods,
      preference: _currentPreference,
    );
  }

  UserPreference get _currentPreference {
    final profile = _profileService.profile;

    if (profile == null) {
      return UserPreference.defaultPreference;
    }

    return UserPreference(
      dietaryPreferences: profile.dietaryTags,
      budgetMin: 0,
      budgetMax: profile.budgetMax ?? 999999,
      distanceLimitMeters: profile.distanceLimitMeters ?? 999999,
      preferredTags: profile.dietaryTags,
      avoidIngredients: const [],
      wasteReductionEnabled: true,
    );
  }

  String get _summaryText {
    final profile = _profileService.profile;
    final preference = _currentPreference;
    final tags = preference.preferredTags.isEmpty
        ? '未設定偏好'
        : preference.preferredTags.take(3).join(' / ');
    final budget = profile?.budgetMax == null
        ? '預算不限'
        : '預算 ${profile!.budgetMax} 元內';
    final distance = profile?.distanceLimitMeters == null
        ? '距離不限'
        : '距離 ${profile!.distanceLimitMeters} 公尺內';

    return '推薦依據：$tags / $budget / $distance';
  }

  void _goToFoodDetail(FoodItem food) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => FoodDetailScreen(food: food)),
    );
  }

  void _refresh() {
    if (mounted) {
      setState(() {});
    }
  }

  void _refreshRecommendations() {
    if (mounted) {
      setState(() {
        recommendedFoods = _buildRecommendations();
      });
    }
  }
}
