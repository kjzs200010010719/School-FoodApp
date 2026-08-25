import 'package:flutter/material.dart';
import 'package:my_app/data/mock_food_repository.dart';
import 'package:my_app/models/food_item.dart';
import 'package:my_app/models/user_preference.dart';
import 'package:my_app/screens/collection_screen.dart';
import 'package:my_app/screens/food_detail_screen.dart';
import 'package:my_app/screens/profile_screen.dart';
import 'package:my_app/screens/recommendation_screen.dart';
import 'package:my_app/screens/search_screen.dart';
import 'package:my_app/screens/wheel_screen.dart';
import 'package:my_app/services/food_search_service.dart';
import 'package:my_app/services/recommendation_service.dart';
import 'package:my_app/services/user_activity_service.dart';
import 'package:my_app/services/user_profile_service.dart';
import 'package:my_app/widgets/food_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final UserActivityService _activityService = UserActivityService.instance;
  final UserProfileService _profileService = UserProfileService.instance;
  final RecommendationService _recommendationService =
      const RecommendationService();
  final TextEditingController _homeSearchController = TextEditingController();
  FoodSearchFilters _homeSearchFilters = const FoodSearchFilters();
  int _currentIndex = 0;

  final List<FoodItem> expiringFoods = MockFoodRepository.expiringFoods;

  @override
  void initState() {
    super.initState();
    _activityService.addListener(_refresh);
    _profileService.addListener(_refresh);
  }

  @override
  void dispose() {
    _activityService.removeListener(_refresh);
    _profileService.removeListener(_refresh);
    _homeSearchController.dispose();
    super.dispose();
  }

  List<String> get _categories {
    return MockFoodRepository.allFoods
        .map((food) => food.category)
        .toSet()
        .toList()
      ..sort();
  }

  List<String> get _tags {
    return MockFoodRepository.allFoods
        .expand((food) => food.tags)
        .toSet()
        .toList()
      ..sort();
  }

  List<FoodItem> get _recommendedFoods {
    return _recommendationService
        .getRecommendations(
          foods: MockFoodRepository.allFoods,
          preference: _currentPreference,
        )
        .take(3)
        .toList();
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

  Future<void> _goToRecommendation() async {
    if (!await _ensureLoggedIn()) {
      return;
    }

    if (mounted) {
      setState(() {
        _currentIndex = 1;
      });
    }
  }

  Future<void> _goToFoodDetail(FoodItem food) async {
    if (!await _ensureLoggedIn()) {
      return;
    }
    if (!mounted) {
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => FoodDetailScreen(food: food)),
    );
  }

  Future<void> _goToSearch({String initialQuery = ''}) async {
    if (!await _ensureLoggedIn()) {
      return;
    }
    if (!mounted) {
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SearchScreen(
          initialQuery: initialQuery,
          initialFilters: _homeSearchFilters,
        ),
      ),
    );
  }

  Future<void> _goToWheel() async {
    if (!await _ensureLoggedIn()) {
      return;
    }
    if (!mounted) {
      return;
    }

    if (mounted) {
      setState(() {
        _currentIndex = 2;
      });
    }
  }

  Future<void> _goToCollection() async {
    if (!await _ensureLoggedIn()) {
      return;
    }
    if (!mounted) {
      return;
    }

    if (mounted) {
      setState(() {
        _currentIndex = 3;
      });
    }
  }

  Future<void> _goToProfile() async {
    if (mounted) {
      setState(() {
        _currentIndex = 4;
      });
    }
  }

  Future<bool> _ensureLoggedIn() async {
    if (_profileService.isLoggedIn) {
      return true;
    }

    if (mounted) {
      setState(() {
        _currentIndex = 4;
      });
    }
    return false;
  }

  void _onNavTap(int index) async {
    if (index == 0) {
      setState(() {
        _currentIndex = 0;
      });
      return;
    }

    if (index == 1) {
      await _goToRecommendation();
      return;
    }

    if (index == 2) {
      await _goToWheel();
      return;
    }

    if (index == 3) {
      await _goToCollection();
      return;
    }

    if (index == 4) {
      setState(() {
        _currentIndex = 4;
      });

      await _goToProfile();
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
      body: IndexedStack(
        index: _currentIndex,
        children: [
          _buildHomeBody(),
          const RecommendationScreen(),
          const WheelScreen(),
          const CollectionScreen(),
          const ProfileScreen(),
        ],
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

  Widget _buildHomeBody() {
    return SafeArea(
      child: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: () => FocusScope.of(context).unfocus(),
        child: SingleChildScrollView(
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(),
              const SizedBox(height: 20),
              _buildSearchBar(),
              _buildHomeActiveFilters(),
              const SizedBox(height: 24),
              _buildQuickActionCard(),
              const SizedBox(height: 24),
              _buildSectionTitle('今日推薦', '根據你的偏好推薦'),
              const SizedBox(height: 12),
              ..._recommendedFoods.map(
                (food) => FoodCard(
                  food: food,
                  isFavorite: _activityService.isFavorite(food.id),
                  onTap: () => _goToFoodDetail(food),
                  onFavoritePressed: () => _toggleFavorite(food),
                ),
              ),
              const SizedBox(height: 24),
              _buildSectionTitle('即期優惠', '優先推薦減少浪費'),
              const SizedBox(height: 12),
              ...expiringFoods.map(
                (food) => FoodCard(
                  food: food,
                  variant: FoodCardVariant.expiring,
                  isFavorite: _activityService.isFavorite(food.id),
                  onTap: () => _goToFoodDetail(food),
                  onFavoritePressed: () => _toggleFavorite(food),
                ),
              ),
              const SizedBox(height: 24),
              _buildDecisionCard(),
            ],
          ),
        ),
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
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(18),
      elevation: 0,
      child: Container(
        padding: const EdgeInsets.only(left: 14, right: 6),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            const Icon(Icons.search_rounded, color: Colors.black54),
            const SizedBox(width: 8),
            Expanded(
              child: TextField(
                controller: _homeSearchController,
                textInputAction: TextInputAction.search,
                onChanged: (_) => setState(() {}),
                onSubmitted: (value) => _submitHomeSearch(),
                decoration: const InputDecoration(
                  hintText: '搜尋你想吃的餐點、店家...',
                  border: InputBorder.none,
                  isDense: true,
                ),
              ),
            ),
            if (_homeSearchController.text.isNotEmpty)
              IconButton(
                tooltip: '清除',
                onPressed: () {
                  setState(() {
                    _homeSearchController.clear();
                  });
                },
                icon: const Icon(Icons.close_rounded),
              ),
            IconButton(
              tooltip: '篩選',
              onPressed: _openHomeFilters,
              icon: const Icon(Icons.tune_rounded),
            ),
            IconButton(
              tooltip: '搜尋',
              onPressed: _submitHomeSearch,
              icon: const Icon(Icons.arrow_forward_rounded),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHomeActiveFilters() {
    final chips = <Widget>[
      if (_homeSearchFilters.expiringOnly)
        InputChip(
          label: const Text('只看即期'),
          onDeleted: () => _updateHomeFilters(
            _homeSearchFilters.copyWith(expiringOnly: false),
          ),
        ),
      ..._homeSearchFilters.categories.map(
        (category) => InputChip(
          label: Text(category),
          onDeleted: () => _toggleHomeCategory(category),
        ),
      ),
      ..._homeSearchFilters.tags.map(
        (tag) =>
            InputChip(label: Text(tag), onDeleted: () => _toggleHomeTag(tag)),
      ),
      if (_homeSearchFilters.maxPrice != null)
        InputChip(
          label: Text('${_homeSearchFilters.maxPrice} 元內'),
          onDeleted: () => _updateHomeFilters(
            _homeSearchFilters.copyWith(clearMaxPrice: true),
          ),
        ),
      if (_homeSearchFilters.maxDistanceMeters != null)
        InputChip(
          label: Text('${_homeSearchFilters.maxDistanceMeters} 公尺內'),
          onDeleted: () => _updateHomeFilters(
            _homeSearchFilters.copyWith(clearMaxDistance: true),
          ),
        ),
    ];

    if (chips.isEmpty) {
      return const SizedBox(height: 0);
    }

    return Padding(
      padding: const EdgeInsets.only(top: 10),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(children: chips),
      ),
    );
  }

  void _openHomeFilters() {
    FocusScope.of(context).unfocus();

    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      backgroundColor: Colors.white,
      builder: (context) {
        var draftFilters = _homeSearchFilters;

        return StatefulBuilder(
          builder: (context, setSheetState) {
            void updateDraft(FoodSearchFilters filters) {
              setSheetState(() {
                draftFilters = filters;
              });
            }

            return SafeArea(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                shrinkWrap: true,
                children: [
                  const Text(
                    '搜尋篩選',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2E3A2F),
                    ),
                  ),
                  const SizedBox(height: 16),
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('只看即期優惠'),
                    value: draftFilters.expiringOnly,
                    onChanged: (value) =>
                        updateDraft(draftFilters.copyWith(expiringOnly: value)),
                  ),
                  const SizedBox(height: 8),
                  _buildHomeFilterSection(
                    title: '餐點類型',
                    children: _categories
                        .map(
                          (category) => FilterChip(
                            label: Text(category),
                            selected: draftFilters.categories.contains(
                              category,
                            ),
                            onSelected: (_) => updateDraft(
                              _homeFiltersWithCategory(draftFilters, category),
                            ),
                          ),
                        )
                        .toList(),
                  ),
                  _buildHomeFilterSection(
                    title: '偏好標籤',
                    children: _tags
                        .map(
                          (tag) => FilterChip(
                            label: Text(tag),
                            selected: draftFilters.tags.contains(tag),
                            onSelected: (_) => updateDraft(
                              _homeFiltersWithTag(draftFilters, tag),
                            ),
                          ),
                        )
                        .toList(),
                  ),
                  _buildHomePriceOptions(draftFilters, updateDraft),
                  _buildHomeDistanceOptions(draftFilters, updateDraft),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () =>
                              updateDraft(const FoodSearchFilters()),
                          child: const Text('清除'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: FilledButton(
                          onPressed: () {
                            _updateHomeFilters(draftFilters);
                            Navigator.pop(context);
                          },
                          child: const Text('套用'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildHomeFilterSection({
    required String title,
    required List<Widget> children,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Color(0xFF2E3A2F),
            ),
          ),
          const SizedBox(height: 8),
          Wrap(spacing: 8, runSpacing: 8, children: children),
        ],
      ),
    );
  }

  Widget _buildHomePriceOptions(
    FoodSearchFilters draftFilters,
    ValueChanged<FoodSearchFilters> onChanged,
  ) {
    const options = [80, 120, 150, 200, 300];

    return _buildHomeFilterSection(
      title: '預算上限',
      children: [
        ChoiceChip(
          label: const Text('不限'),
          selected: draftFilters.maxPrice == null,
          onSelected: (_) =>
              onChanged(draftFilters.copyWith(clearMaxPrice: true)),
        ),
        ...options.map(
          (price) => ChoiceChip(
            label: Text('$price 元內'),
            selected: draftFilters.maxPrice == price,
            onSelected: (selected) => onChanged(
              draftFilters.copyWith(
                maxPrice: selected ? price : null,
                clearMaxPrice: !selected,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHomeDistanceOptions(
    FoodSearchFilters draftFilters,
    ValueChanged<FoodSearchFilters> onChanged,
  ) {
    const options = [500, 800, 1000, 1500];

    return _buildHomeFilterSection(
      title: '距離上限',
      children: [
        ChoiceChip(
          label: const Text('不限'),
          selected: draftFilters.maxDistanceMeters == null,
          onSelected: (_) =>
              onChanged(draftFilters.copyWith(clearMaxDistance: true)),
        ),
        ...options.map(
          (distance) => ChoiceChip(
            label: Text('$distance 公尺內'),
            selected: draftFilters.maxDistanceMeters == distance,
            onSelected: (selected) => onChanged(
              draftFilters.copyWith(
                maxDistanceMeters: selected ? distance : null,
                clearMaxDistance: !selected,
              ),
            ),
          ),
        ),
      ],
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
                  onPressed: _goToWheel,
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
              onPressed: _goToWheel,
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

  Future<void> _toggleFavorite(FoodItem food) async {
    if (!await _ensureLoggedIn()) {
      return;
    }

    _activityService.toggleFavorite(food);
  }

  void _submitHomeSearch() {
    FocusScope.of(context).unfocus();
    _activityService.addSearchLog(
      keyword: _homeSearchController.text,
      filterSummary: _homeSearchFilters.summaryLabel,
    );
    _goToSearch(initialQuery: _homeSearchController.text.trim());
  }

  void _updateHomeFilters(FoodSearchFilters filters) {
    setState(() {
      _homeSearchFilters = filters;
    });
  }

  void _toggleHomeCategory(String category) {
    _updateHomeFilters(_homeFiltersWithCategory(_homeSearchFilters, category));
  }

  void _toggleHomeTag(String tag) {
    _updateHomeFilters(_homeFiltersWithTag(_homeSearchFilters, tag));
  }

  FoodSearchFilters _homeFiltersWithCategory(
    FoodSearchFilters filters,
    String category,
  ) {
    final categories = {...filters.categories};
    categories.contains(category)
        ? categories.remove(category)
        : categories.add(category);
    return filters.copyWith(categories: categories);
  }

  FoodSearchFilters _homeFiltersWithTag(FoodSearchFilters filters, String tag) {
    final tags = {...filters.tags};
    tags.contains(tag) ? tags.remove(tag) : tags.add(tag);
    return filters.copyWith(tags: tags);
  }

  void _refresh() {
    if (mounted) {
      setState(() {});
    }
  }
}
