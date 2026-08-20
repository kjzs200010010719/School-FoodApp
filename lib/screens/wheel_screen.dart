import 'package:flutter/material.dart';
import 'package:my_app/data/mock_food_repository.dart';
import 'package:my_app/models/food_item.dart';
import 'package:my_app/screens/food_detail_screen.dart';
import 'package:my_app/services/food_search_service.dart';
import 'package:my_app/services/food_wheel_service.dart';
import 'package:my_app/widgets/food_card.dart';

class WheelScreen extends StatefulWidget {
  const WheelScreen({super.key});

  @override
  State<WheelScreen> createState() => _WheelScreenState();
}

class _WheelScreenState extends State<WheelScreen>
    with SingleTickerProviderStateMixin {
  final FoodWheelService _wheelService = const FoodWheelService();
  late final AnimationController _animationController;
  late final Animation<double> _turns;

  FoodSearchFilters _filters = const FoodSearchFilters(
    maxPrice: 150,
    maxDistanceMeters: 1000,
  );
  FoodItem? _selectedFood;

  List<FoodItem> get _candidates {
    return _wheelService.getCandidates(
      foods: MockFoodRepository.allFoods,
      filters: _filters,
    );
  }

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _turns = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOutCubic),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final candidates = _candidates;

    return Scaffold(
      backgroundColor: const Color(0xFFF7F9F4),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF7F9F4),
        elevation: 0,
        centerTitle: true,
        title: const Text(
          '食物轉盤',
          style: TextStyle(
            color: Color(0xFF2E3A2F),
            fontWeight: FontWeight.bold,
          ),
        ),
        iconTheme: const IconThemeData(color: Color(0xFF2E3A2F)),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
        children: [
          _buildIntroCard(candidates.length),
          const SizedBox(height: 18),
          _buildFilterPanel(),
          const SizedBox(height: 18),
          _buildWheelResult(candidates),
          const SizedBox(height: 18),
          _buildCandidatePreview(candidates),
        ],
      ),
    );
  }

  Widget _buildIntroCard(int candidateCount) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFF2F3E30),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '先篩選，再決定',
            style: TextStyle(color: Colors.white70, fontSize: 14),
          ),
          const SizedBox(height: 8),
          const Text(
            '從符合預算、距離與偏好的餐點中抽選',
            style: TextStyle(
              color: Colors.white,
              fontSize: 21,
              fontWeight: FontWeight.bold,
              height: 1.35,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            '目前候選餐點：$candidateCount 項，會提高即期優惠餐點的抽中權重。',
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

  Widget _buildFilterPanel() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
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
          const Text(
            '轉盤條件',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF2E3A2F),
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              FilterChip(
                label: const Text('只看即期優惠'),
                selected: _filters.expiringOnly,
                onSelected: (selected) =>
                    _updateFilters(_filters.copyWith(expiringOnly: selected)),
              ),
              FilterChip(
                label: const Text('高蛋白'),
                selected: _filters.tags.contains('高蛋白'),
                onSelected: (_) => _toggleTag('高蛋白'),
              ),
              FilterChip(
                label: const Text('低脂'),
                selected: _filters.tags.contains('低脂'),
                onSelected: (_) => _toggleTag('低脂'),
              ),
              FilterChip(
                label: const Text('均衡'),
                selected: _filters.tags.contains('均衡'),
                onSelected: (_) => _toggleTag('均衡'),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: _buildOptionMenu(
                  label: '預算',
                  value: _filters.maxPrice,
                  options: const [80, 120, 150, 200],
                  suffix: '元內',
                  onChanged: (price) =>
                      _updateFilters(_filters.copyWith(maxPrice: price)),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildOptionMenu(
                  label: '距離',
                  value: _filters.maxDistanceMeters,
                  options: const [500, 800, 1000],
                  suffix: '公尺內',
                  onChanged: (distance) => _updateFilters(
                    _filters.copyWith(maxDistanceMeters: distance),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildOptionMenu({
    required String label,
    required int? value,
    required List<int> options,
    required String suffix,
    required ValueChanged<int> onChanged,
  }) {
    return DropdownButtonFormField<int>(
      initialValue: value,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 10,
        ),
      ),
      items: options
          .map(
            (option) => DropdownMenuItem<int>(
              value: option,
              child: Text('$option $suffix'),
            ),
          )
          .toList(),
      onChanged: (option) {
        if (option != null) {
          onChanged(option);
        }
      },
    );
  }

  Widget _buildWheelResult(List<FoodItem> candidates) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFBF2),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFFFE3A3)),
      ),
      child: Column(
        children: [
          RotationTransition(
            turns: _turns,
            child: Container(
              width: 112,
              height: 112,
              decoration: const BoxDecoration(
                color: Color(0xFFFFD86B),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.casino_rounded,
                size: 58,
                color: Color(0xFF2F3E30),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            _selectedFood == null ? '按下轉盤，幫你選出一餐' : _selectedFood!.name,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Color(0xFF2E3A2F),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _selectedFood == null
                ? '候選餐點會先依條件篩選，並提高即期餐點權重。'
                : '${_selectedFood!.storeName} / ${_selectedFood!.priceLabel} / ${_selectedFood!.distanceLabel}',
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.black54, height: 1.5),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: FilledButton.icon(
                  onPressed: candidates.isEmpty
                      ? null
                      : () => _spin(candidates),
                  icon: const Icon(Icons.play_arrow_rounded),
                  label: const Text('開始轉盤'),
                ),
              ),
              if (_selectedFood != null) ...[
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _goToFoodDetail(_selectedFood!),
                    icon: const Icon(Icons.receipt_long_rounded),
                    label: const Text('看詳情'),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCandidatePreview(List<FoodItem> candidates) {
    if (candidates.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 24),
          child: Text(
            '目前沒有符合條件的餐點，請放寬預算或距離。',
            style: TextStyle(color: Colors.black54),
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '候選餐點',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Color(0xFF2E3A2F),
          ),
        ),
        const SizedBox(height: 12),
        ...candidates
            .take(3)
            .map(
              (food) => FoodCard(
                food: food,
                showDistance: true,
                variant: food.isExpiringSoon
                    ? FoodCardVariant.expiring
                    : FoodCardVariant.recommendation,
                onTap: () => _goToFoodDetail(food),
              ),
            ),
      ],
    );
  }

  void _spin(List<FoodItem> candidates) {
    final selectedFood = _wheelService.spin(candidates: candidates);

    setState(() {
      _selectedFood = selectedFood;
    });

    _animationController.forward(from: 0);
  }

  void _updateFilters(FoodSearchFilters filters) {
    setState(() {
      _filters = filters;
      _selectedFood = null;
    });
  }

  void _toggleTag(String tag) {
    final tags = {..._filters.tags};
    tags.contains(tag) ? tags.remove(tag) : tags.add(tag);
    _updateFilters(_filters.copyWith(tags: tags));
  }

  void _goToFoodDetail(FoodItem food) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => FoodDetailScreen(food: food)),
    );
  }
}
