import 'package:flutter/material.dart';
import 'package:my_app/data/mock_food_repository.dart';
import 'package:my_app/models/food_item.dart';
import 'package:my_app/screens/food_detail_screen.dart';
import 'package:my_app/screens/recommendation_screen.dart';
import 'package:my_app/widgets/food_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  final List<FoodItem> recommendedFoods = MockFoodRepository.recommendedPreview;
  final List<FoodItem> expiringFoods = MockFoodRepository.expiringFoods;

  Future<void> _goToRecommendation() async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const RecommendationScreen()),
    );

    if (mounted) {
      setState(() {
        _currentIndex = 0;
      });
    }
  }

  void _goToFoodDetail(FoodItem food) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => FoodDetailScreen(food: food)),
    );
  }

  void _onNavTap(int index) async {
    if (index == 0) {
      setState(() {
        _currentIndex = 0;
      });
      return;
    }

    if (index == 1) {
      setState(() {
        _currentIndex = 1;
      });

      await _goToRecommendation();

      if (mounted) {
        setState(() {
          _currentIndex = 0;
        });
      }
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('目前點擊的是：${_navTitle(index)}'),
        duration: const Duration(seconds: 1),
      ),
    );
  }

  String _navTitle(int index) {
    switch (index) {
      case 0:
        return '首頁';
      case 1:
        return '推薦';
      case 2:
        return '轉盤';
      case 3:
        return '收藏';
      case 4:
        return '我的';
      default:
        return '未知';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F9F4),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(),
              const SizedBox(height: 20),
              _buildSearchBar(),
              const SizedBox(height: 24),
              _buildQuickActionCard(),
              const SizedBox(height: 24),
              _buildSectionTitle('今日推薦', '根據你的偏好推薦'),
              const SizedBox(height: 12),
              ...recommendedFoods.map(
                (food) =>
                    FoodCard(food: food, onTap: () => _goToFoodDetail(food)),
              ),
              const SizedBox(height: 24),
              _buildSectionTitle('即期優惠', '優先推薦減少浪費'),
              const SizedBox(height: 12),
              ...expiringFoods.map(
                (food) => FoodCard(
                  food: food,
                  variant: FoodCardVariant.expiring,
                  onTap: () => _goToFoodDetail(food),
                ),
              ),
              const SizedBox(height: 24),
              _buildDecisionCard(),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: _onNavTap,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: const Color(0xFF4E8D57),
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home_rounded), label: '首頁'),
          BottomNavigationBarItem(
            icon: Icon(Icons.recommend_rounded),
            label: '推薦',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.casino_rounded),
            label: '轉盤',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.favorite_rounded),
            label: '收藏',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_rounded),
            label: '我的',
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        Container(
          width: 52,
          height: 52,
          decoration: BoxDecoration(
            color: const Color(0xFFDDEED9),
            borderRadius: BorderRadius.circular(16),
          ),
          child: const Icon(
            Icons.eco_rounded,
            color: Color(0xFF4E8D57),
            size: 30,
          ),
        ),
        const SizedBox(width: 12),
        const Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '膳解人意',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2E3A2F),
                ),
              ),
              SizedBox(height: 4),
              Text(
                '不用想，好選擇都在這!',
                style: TextStyle(fontSize: 14, color: Colors.black54),
              ),
            ],
          ),
        ),
        IconButton(
          onPressed: () {},
          icon: const Icon(Icons.notifications_none_rounded),
        ),
      ],
    );
  }

  Widget _buildSearchBar() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: TextField(
        decoration: InputDecoration(
          hintText: '搜尋你想吃的餐點、店家...',
          prefixIcon: const Icon(Icons.search_rounded),
          suffixIcon: IconButton(
            onPressed: () {},
            icon: const Icon(Icons.tune_rounded),
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(18),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: Colors.white,
        ),
      ),
    );
  }

  Widget _buildQuickActionCard() {
    return Container(
      width: double.infinity,
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
            '快速開始',
            style: TextStyle(color: Colors.white70, fontSize: 14),
          ),
          const SizedBox(height: 8),
          const Text(
            '不知道吃什麼？\n先看看我的推薦吧!',
            style: TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.bold,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: _goToRecommendation,
                  icon: const Icon(Icons.recommend),
                  label: const Text('查看推薦'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: const Color(0xFF4E8D57),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 0,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.casino_rounded),
                  label: const Text('轉盤決定'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.white,
                    side: const BorderSide(color: Colors.white70),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title, String subtitle) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF2E3A2F),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: const TextStyle(fontSize: 13, color: Colors.black54),
            ),
          ],
        ),
        TextButton(onPressed: _goToRecommendation, child: const Text('更多')),
      ],
    );
  }

  Widget _buildDecisionCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF2F3E30),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '還是選不出來？',
            style: TextStyle(color: Colors.white70, fontSize: 14),
          ),
          const SizedBox(height: 8),
          const Text(
            '交給轉盤幫你做決定',
            style: TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 10),
          const Text(
            '根據你的偏好、預算與條件，從符合項目中幫你抽出最適合的一餐。',
            style: TextStyle(color: Colors.white70, fontSize: 14, height: 1.5),
          ),
          const SizedBox(height: 18),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.casino_rounded),
              label: const Text('開始轉盤'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFFD86B),
                foregroundColor: const Color(0xFF2F3E30),
                padding: const EdgeInsets.symmetric(vertical: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
