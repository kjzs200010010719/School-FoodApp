import 'package:flutter/material.dart';
import 'package:my_app/screens/recommendation_screen.dart';

//HomeScreen是有狀態元件（StatefulWidget），因為底部導覽列需要追蹤目前選取的index。
//HomeScreen的createState() 回傳對應的State物件_HomeScreenState。
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

//State類別。_currentIndex紀錄底部導覽列目前選到第幾個項目
//，預設為0（首頁）。底線前綴_代表私有變數。
class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  //定義「今日推薦」的資料列表，每筆資料是一個Map，key為String，value可以是任何型別（dynamic）。
  //final表示這個列表本身的參考不可改變。
  final List<Map<String, dynamic>> recommendedFoods = [
    {
      'name': '舒肥雞胸餐盒',
      'store': '健康餐盒店',
      'price': 120,
      'tag': '高蛋白',
      'reason': '符合你的高蛋白需求',
      'icon': Icons.lunch_dining,
    },
    {
      'name': '番茄義大利麵',
      'store': '義式小館',
      'price': 150,
      'tag': '熱門',
      'reason': '符合你的預算範圍',
      'icon': Icons.restaurant,
    },
  ];

  //定義「即期優惠」
  final List<Map<String, dynamic>> expiringFoods = [
    {
      'name': '鮪魚三明治',
      'store': '晨光早餐店',
      'price': 45,
      'discount': '7折',
      'timeLeft': '剩 2 小時',
      'icon': Icons.breakfast_dining,
    },
    {
      'name': '水果優格杯',
      'store': '輕食專賣店',
      'price': 60,
      'discount': '8折',
      'timeLeft': '剩 3 小時',
      'icon': Icons.icecream,
    },
  ];

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

  //底部導覽列被點擊時呼叫。
  //setState()通知Flutter狀態改變、需要重新渲染，內部將_currentIndex更新為被點擊的項目編號。
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

  //顯示一個底部提示條（Snackbar），
  //內容為目前點擊的頁籤名稱，持續1秒後自動消失。${}是Dart的字串插值語法。
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

  //回傳Scaffold，這是Flutter頁面的基本骨架，
  //提供body、bottomNavigationBar等插槽。背景設為淡綠灰色。
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F9F4),
      //讓內容自動避開螢幕的瀏海、狀態列、Home指示條等系統UI區域。
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
              ...recommendedFoods.map((food) => _buildRecommendCard(food)),
              const SizedBox(height: 24),
              _buildSectionTitle('即期優惠', '優先推薦減少浪費'),
              const SizedBox(height: 12),
              ...expiringFoods.map((food) => _buildExpiringCard(food)),
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
            color: Colors.black.withOpacity(0.05),
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
                  onPressed: () {
                    _goToRecommendation();
                    debugPrint('有點到查看推薦');
                  },
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
        TextButton(
          onPressed: () {
            _goToRecommendation();
          },
          child: const Text('更多'),
        ),
      ],
    );
  }

  Widget _buildRecommendCard(Map<String, dynamic> food) {
    return GestureDetector(
      onTap: () {
        _goToRecommendation();
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 14),
        padding: const EdgeInsets.all(16),
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
          children: [
            Container(
              width: 72,
              height: 72,
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
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _buildTag(food['tag']),
                      _buildTag('NT\$ ${food['price']}'),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    food['reason'],
                    style: const TextStyle(
                      fontSize: 13,
                      color: Color(0xFF4E8D57),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            IconButton(
              onPressed: () {},
              icon: const Icon(
                Icons.favorite_border_rounded,
                color: Colors.redAccent,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExpiringCard(Map<String, dynamic> food) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFBF2),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFFFFE3A3)),
      ),
      child: Row(
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: const Color(0xFFFFF1CC),
              borderRadius: BorderRadius.circular(18),
            ),
            child: Icon(food['icon'], size: 34, color: const Color(0xFFD68A00)),
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
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _buildWarningTag(food['discount']),
                    _buildWarningTag(food['timeLeft']),
                    _buildWarningTag('NT\$ ${food['price']}'),
                  ],
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.bookmark_border_rounded),
          ),
        ],
      ),
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

  Widget _buildWarningTag(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF1CC),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 12,
          color: Color(0xFFD68A00),
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
