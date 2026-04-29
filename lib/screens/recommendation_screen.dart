import 'package:flutter/material.dart';

class RecommendationScreen extends StatefulWidget {
  const RecommendationScreen({super.key});

  @override
  State<RecommendationScreen> createState() => _RecommendationScreenState();
}

class _RecommendationScreenState extends State<RecommendationScreen> {
  final List<Map<String, dynamic>> recommendedFoods = [
    {
      'name': '舒肥雞胸健康餐',
      'store': '輕食能量館',
      'price': 120,
      'tag': '高蛋白',
      'reason': '符合你的高蛋白需求',
      'distance': '距離 450 公尺',
      'icon': Icons.lunch_dining,
      'isFavorite': false,
    },
    {
      'name': '鮭魚藜麥沙拉',
      'store': '原味沙拉吧',
      'price': 135,
      'tag': '低脂',
      'reason': '符合你的低脂與均衡需求',
      'distance': '距離 600 公尺',
      'icon': Icons.set_meal,
      'isFavorite': true,
    },
    {
      'name': '日式豆腐和食',
      'store': '禾食堂',
      'price': 100,
      'tag': '均衡',
      'reason': '符合你的預算範圍',
      'distance': '距離 700 公尺',
      'icon': Icons.rice_bowl,
      'isFavorite': false,
    },
    {
      'name': '番茄雞肉義大利麵',
      'store': '義式小館',
      'price': 150,
      'tag': '熱門',
      'reason': '使用者評價高，且符合你的偏好',
      'distance': '距離 900 公尺',
      'icon': Icons.restaurant,
      'isFavorite': false,
    },
  ];

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
                return _buildFoodCard(food, index);
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
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('今日推薦結果', style: TextStyle(color: Colors.white70, fontSize: 14)),
          SizedBox(height: 8),
          Text(
            '依照你的偏好、預算與距離，\n幫你挑出最適合的餐點',
            style: TextStyle(
              color: Colors.white,
              fontSize: 21,
              fontWeight: FontWeight.bold,
              height: 1.4,
            ),
          ),
          SizedBox(height: 10),
          Text(
            '推薦依據：高蛋白 / 預算 100-150 元 / 距離 1 公里內',
            style: TextStyle(color: Colors.white70, fontSize: 13, height: 1.5),
          ),
        ],
      ),
    );
  }

  Widget _buildFoodCard(Map<String, dynamic> food, int index) {
    return GestureDetector(
      onTap: () {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('你點選了：${food['name']}'),
            duration: const Duration(seconds: 1),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 14),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(22),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 74,
              height: 74,
              decoration: BoxDecoration(
                color: const Color(0xFFEAF5E8),
                borderRadius: BorderRadius.circular(18),
              ),
              child: Icon(
                food['icon'],
                size: 34,
                color: const Color(0xFF4E8D57),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    food['name'],
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2E3A2F),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    food['store'],
                    style: const TextStyle(fontSize: 13, color: Colors.black54),
                  ),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _buildTag(food['tag']),
                      _buildTag('NT\$ ${food['price']}'),
                      _buildTag(food['distance']),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(
                        Icons.auto_awesome_rounded,
                        size: 16,
                        color: Color(0xFF4E8D57),
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          food['reason'],
                          style: const TextStyle(
                            fontSize: 13,
                            color: Color(0xFF4E8D57),
                            fontWeight: FontWeight.w600,
                            height: 1.4,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            IconButton(
              onPressed: () {
                setState(() {
                  recommendedFoods[index]['isFavorite'] =
                      !recommendedFoods[index]['isFavorite'];
                });
              },
              icon: Icon(
                food['isFavorite']
                    ? Icons.favorite_rounded
                    : Icons.favorite_border_rounded,
                color: Colors.redAccent,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTag(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFFEAF5E8),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 12,
          color: Color(0xFF4E8D57),
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
