import 'package:flutter/material.dart';
import 'package:my_app/data/mock_food_repository.dart';
import 'package:my_app/models/user_profile.dart';
import 'package:my_app/services/user_activity_service.dart';
import 'package:my_app/services/user_profile_service.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({
    super.key,
    this.onOpenCollectionTab,
    this.onLoginComplete,
  });

  final ValueChanged<int>? onOpenCollectionTab;
  final VoidCallback? onLoginComplete;

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final UserProfileService _profileService = UserProfileService.instance;
  final UserActivityService _activityService = UserActivityService.instance;

  @override
  void initState() {
    super.initState();
    _profileService.addListener(_refresh);
    _activityService.addListener(_refresh);
  }

  @override
  void dispose() {
    _profileService.removeListener(_refresh);
    _activityService.removeListener(_refresh);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final profile = _profileService.profile;
    final title = profile == null ? '登入' : '我的';

    return Scaffold(
      backgroundColor: const Color(0xFFF7F9F4),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF7F9F4),
        elevation: 0,
        centerTitle: true,
        title: Text(
          title,
          style: TextStyle(
            color: Color(0xFF2E3A2F),
            fontWeight: FontWeight.bold,
          ),
        ),
        iconTheme: const IconThemeData(color: Color(0xFF2E3A2F)),
      ),
      body: SafeArea(
        child: profile == null ? _buildLoginView() : _buildProfileView(profile),
      ),
    );
  }

  Widget _buildLoginView() {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 24),
      children: [
        Container(
          padding: const EdgeInsets.all(22),
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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(
                Icons.account_circle_rounded,
                color: Color(0xFF4E8D57),
                size: 54,
              ),
              const SizedBox(height: 14),
              const Text(
                '建立你的飲食偏好',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2E3A2F),
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                '先使用測試登入建立本機會員資料，後續可替換為正式註冊與 MySQL/API。',
                style: TextStyle(color: Colors.black54, height: 1.5),
              ),
              const SizedBox(height: 18),
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: _loginWithDemo,
                  icon: const Icon(Icons.login_rounded),
                  label: const Text('測試登入'),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildProfileView(UserProfile profile) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
      children: [
        _buildProfileHeader(profile),
        const SizedBox(height: 16),
        _buildStats(),
        const SizedBox(height: 16),
        _buildHealthSummarySection(),
        const SizedBox(height: 16),
        _buildPreferenceSection(profile),
        const SizedBox(height: 16),
        _buildAccountActions(profile),
      ],
    );
  }

  Widget _buildProfileHeader(UserProfile profile) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
      ),
      child: Row(
        children: [
          Container(
            width: 70,
            height: 70,
            decoration: const BoxDecoration(
              color: Color(0xFFEAF5E8),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.person_rounded,
              color: Color(0xFF4E8D57),
              size: 38,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  profile.name,
                  style: const TextStyle(
                    fontSize: 21,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2E3A2F),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  profile.email,
                  style: const TextStyle(color: Colors.black54),
                ),
                const SizedBox(height: 4),
                Text(
                  profile.phone,
                  style: const TextStyle(color: Colors.black54),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStats() {
    return SizedBox(
      height: 118,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          _buildStatTile(
            icon: Icons.favorite_rounded,
            title: '收藏',
            value: '${_activityService.favorites.length}',
            onTap: () => widget.onOpenCollectionTab?.call(0),
          ),
          const SizedBox(width: 12),
          _buildStatTile(
            icon: Icons.history_rounded,
            title: '瀏覽紀錄',
            value: '${_activityService.history.length}',
            onTap: () => widget.onOpenCollectionTab?.call(1),
          ),
          const SizedBox(width: 12),
          _buildStatTile(
            icon: Icons.receipt_long_rounded,
            title: '點餐紀錄',
            value: '${_activityService.purchaseRecords.length}',
            onTap: () => widget.onOpenCollectionTab?.call(3),
          ),
        ],
      ),
    );
  }

  Widget _buildStatTile({
    required IconData icon,
    required String title,
    required String value,
    VoidCallback? onTap,
  }) {
    return SizedBox(
      width: 150,
      height: 118,
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        child: InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(icon, color: const Color(0xFF4E8D57), size: 22),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(color: Colors.black54),
                      ),
                    ),
                    if (onTap != null)
                      const Icon(
                        Icons.chevron_right_rounded,
                        color: Colors.black38,
                        size: 18,
                      ),
                  ],
                ),
                const Spacer(),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Text(
                    value,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2E3A2F),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHealthSummarySection() {
    final summary = _buildTodayHealthSummary();

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: const Color(0xFFEAF5E8),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.monitor_heart_rounded,
                  color: Color(0xFF4E8D57),
                  size: 22,
                ),
              ),
              const SizedBox(width: 10),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '今日健康摘要',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF2E3A2F),
                      ),
                    ),
                    SizedBox(height: 2),
                    Text(
                      '依購買紀錄估算攝取狀態',
                      style: TextStyle(fontSize: 13, color: Colors.black54),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (summary.mealCount == 0)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFFF7F9F4),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Text(
                '尚無今日點餐紀錄，完成結帳後會自動累計熱量與營養素。',
                style: TextStyle(color: Colors.black54, height: 1.5),
              ),
            )
          else ...[
            ClipRRect(
              borderRadius: BorderRadius.circular(999),
              child: LinearProgressIndicator(
                value: summary.calorieProgress,
                minHeight: 10,
                backgroundColor: const Color(0xFFEAF5E8),
                valueColor: const AlwaysStoppedAnimation(Color(0xFF4E8D57)),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildHealthMetric(
                    '熱量',
                    '${summary.calories} kcal',
                    '建議值 ${summary.dailyCalorieTarget} kcal',
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _buildHealthMetric(
                    '餐點',
                    '${summary.mealCount} 份',
                    '${summary.totalWeightGrams} g',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: _buildHealthMetric(
                    '蛋白質',
                    '${summary.proteinGrams} g',
                    '',
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _buildHealthMetric('脂肪', '${summary.fatGrams} g', ''),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _buildHealthMetric(
                    '碳水',
                    '${summary.carbsGrams} g',
                    '',
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildHealthMetric(String title, String value, String subtitle) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF7F9F4),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 12, color: Colors.black54),
          ),
          const SizedBox(height: 4),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color(0xFF2E3A2F),
              ),
            ),
          ),
          if (subtitle.isNotEmpty) ...[
            const SizedBox(height: 3),
            Text(
              subtitle,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 11, color: Colors.black45),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildPreferenceSection(UserProfile profile) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                '飲食偏好',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2E3A2F),
                ),
              ),
              TextButton.icon(
                onPressed: () => _openEditSheet(profile),
                icon: const Icon(Icons.edit_rounded),
                label: const Text('編輯'),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: profile.dietaryTags
                .map((tag) => Chip(label: Text(tag)))
                .toList(),
          ),
          const SizedBox(height: 14),
          _buildPreferenceRow('預算上限', _budgetLabel(profile.budgetMax)),
          _buildPreferenceRow(
            '距離上限',
            _distanceLabel(profile.distanceLimitMeters),
          ),
        ],
      ),
    );
  }

  Widget _buildPreferenceRow(String title, String value) {
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Row(
        children: [
          Expanded(
            child: Text(title, style: const TextStyle(color: Colors.black54)),
          ),
          Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Color(0xFF2E3A2F),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAccountActions(UserProfile profile) {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: () => _openEditSheet(profile),
            icon: const Icon(Icons.manage_accounts_rounded),
            label: const Text('編輯會員資料'),
          ),
        ),
        const SizedBox(height: 10),
        SizedBox(
          width: double.infinity,
          child: TextButton.icon(
            onPressed: _profileService.logout,
            icon: const Icon(Icons.logout_rounded),
            label: const Text('登出'),
          ),
        ),
      ],
    );
  }

  void _openEditSheet(UserProfile profile) {
    final nameController = TextEditingController(text: profile.name);
    final emailController = TextEditingController(text: profile.email);
    final phoneController = TextEditingController(text: profile.phone);
    var selectedTags = {...profile.dietaryTags};
    int? budgetMax = profile.budgetMax;
    int? distanceLimit = profile.distanceLimitMeters;
    final availableTags =
        MockFoodRepository.allFoods.expand((food) => food.tags).toSet().toList()
          ..sort();

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            void toggleTag(String tag) {
              setSheetState(() {
                selectedTags.contains(tag)
                    ? selectedTags.remove(tag)
                    : selectedTags.add(tag);
              });
            }

            return SafeArea(
              child: Padding(
                padding: EdgeInsets.fromLTRB(
                  20,
                  0,
                  20,
                  MediaQuery.of(context).viewInsets.bottom + 20,
                ),
                child: ListView(
                  shrinkWrap: true,
                  children: [
                    const Text(
                      '編輯會員資料',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF2E3A2F),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: nameController,
                      decoration: const InputDecoration(labelText: '姓名'),
                    ),
                    TextField(
                      controller: emailController,
                      decoration: const InputDecoration(labelText: 'Email'),
                    ),
                    TextField(
                      controller: phoneController,
                      decoration: const InputDecoration(labelText: '電話'),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      '偏好標籤',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: availableTags
                          .map(
                            (tag) => FilterChip(
                              label: Text(tag),
                              selected: selectedTags.contains(tag),
                              onSelected: (_) => toggleTag(tag),
                            ),
                          )
                          .toList(),
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<int?>(
                      initialValue: budgetMax,
                      decoration: const InputDecoration(labelText: '預算上限'),
                      items: <int?>[80, 120, 150, 200, 300, null]
                          .map(
                            (value) => DropdownMenuItem<int?>(
                              value: value,
                              child: Text(value == null ? '不限' : '$value 元'),
                            ),
                          )
                          .toList(),
                      onChanged: (value) {
                        setSheetState(() {
                          budgetMax = value;
                        });
                      },
                    ),
                    DropdownButtonFormField<int?>(
                      initialValue: distanceLimit,
                      decoration: const InputDecoration(labelText: '距離上限'),
                      items: <int?>[500, 800, 1000, 1500, null]
                          .map(
                            (value) => DropdownMenuItem<int?>(
                              value: value,
                              child: Text(value == null ? '不限' : '$value 公尺'),
                            ),
                          )
                          .toList(),
                      onChanged: (value) {
                        setSheetState(() {
                          distanceLimit = value;
                        });
                      },
                    ),
                    const SizedBox(height: 18),
                    FilledButton(
                      onPressed: () {
                        _profileService.updateProfile(
                          profile.copyWith(
                            name: nameController.text.trim(),
                            email: emailController.text.trim(),
                            phone: phoneController.text.trim(),
                            dietaryTags: selectedTags.toList(),
                            budgetMax: budgetMax,
                            distanceLimitMeters: distanceLimit,
                            clearBudgetMax: budgetMax == null,
                            clearDistanceLimit: distanceLimit == null,
                          ),
                        );
                        Navigator.pop(context);
                      },
                      child: const Text('儲存'),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _refresh() {
    if (mounted) {
      setState(() {});
    }
  }

  void _loginWithDemo() {
    _profileService.loginWithDemo();
    widget.onLoginComplete?.call();
  }

  String _budgetLabel(int? budgetMax) {
    return budgetMax == null ? '不限' : '$budgetMax 元';
  }

  String _distanceLabel(int? distanceLimitMeters) {
    return distanceLimitMeters == null ? '不限' : '$distanceLimitMeters 公尺';
  }

  _HealthSummary _buildTodayHealthSummary() {
    const dailyCalorieTarget = 1800;
    final today = DateTime.now();
    var mealCount = 0;
    var calories = 0;
    var totalWeightGrams = 0;
    var proteinGrams = 0;
    var fatGrams = 0;
    var carbsGrams = 0;

    for (final record in _activityService.purchaseRecords) {
      if (!_isSameDate(record.purchasedAt, today)) {
        continue;
      }

      for (final item in record.items) {
        mealCount += item.quantity;
        calories += item.food.calories * item.quantity;
        totalWeightGrams += item.food.weightGrams * item.quantity;
        proteinGrams += item.food.proteinGrams * item.quantity;
        fatGrams += item.food.fatGrams * item.quantity;
        carbsGrams += item.food.carbsGrams * item.quantity;
      }
    }

    return _HealthSummary(
      mealCount: mealCount,
      calories: calories,
      totalWeightGrams: totalWeightGrams,
      proteinGrams: proteinGrams,
      fatGrams: fatGrams,
      carbsGrams: carbsGrams,
      dailyCalorieTarget: dailyCalorieTarget,
    );
  }

  bool _isSameDate(DateTime first, DateTime second) {
    return first.year == second.year &&
        first.month == second.month &&
        first.day == second.day;
  }
}

class _HealthSummary {
  const _HealthSummary({
    required this.mealCount,
    required this.calories,
    required this.totalWeightGrams,
    required this.proteinGrams,
    required this.fatGrams,
    required this.carbsGrams,
    required this.dailyCalorieTarget,
  });

  final int mealCount;
  final int calories;
  final int totalWeightGrams;
  final int proteinGrams;
  final int fatGrams;
  final int carbsGrams;
  final int dailyCalorieTarget;

  double get calorieProgress {
    if (dailyCalorieTarget == 0) {
      return 0;
    }

    return (calories / dailyCalorieTarget).clamp(0, 1).toDouble();
  }
}
