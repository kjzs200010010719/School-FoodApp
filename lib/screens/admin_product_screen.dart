import 'package:flutter/material.dart';
import 'package:my_app/data/mock_food_repository.dart';
import 'package:my_app/models/merchant_account.dart';
import 'package:my_app/models/product_listing_draft.dart';
import 'package:my_app/services/merchant_auth_service.dart';

class AdminProductScreen extends StatefulWidget {
  const AdminProductScreen({super.key, this.merchant});

  final MerchantAccount? merchant;

  @override
  State<AdminProductScreen> createState() => _AdminProductScreenState();
}

class _AdminProductScreenState extends State<AdminProductScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _stockController = TextEditingController();
  final TextEditingController _tagsController = TextEditingController();
  final TextEditingController _ingredientsController = TextEditingController();
  final TextEditingController _caloriesController = TextEditingController();
  final TextEditingController _weightController = TextEditingController();
  final TextEditingController _proteinController = TextEditingController();
  final TextEditingController _fatController = TextEditingController();
  final TextEditingController _carbsController = TextEditingController();
  final TextEditingController _imageUrlController = TextEditingController();

  final List<ProductListingDraft> _drafts = [];
  final Set<int> _selectedWeekdays = {
    DateTime.monday,
    DateTime.tuesday,
    DateTime.wednesday,
    DateTime.thursday,
    DateTime.friday,
  };

  late final MerchantAccount _merchant;
  late String _category = _categories.first;
  late String _storeName;

  List<String> get _categories {
    return MockFoodRepository.allFoods
        .map((food) => food.category)
        .toSet()
        .toList()
      ..sort();
  }

  @override
  void initState() {
    super.initState();
    _merchant =
        widget.merchant ??
        MerchantAuthService.instance.account ??
        MerchantAccount.demo;
    _storeName = _merchant.primaryStoreName;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    _stockController.dispose();
    _tagsController.dispose();
    _ingredientsController.dispose();
    _caloriesController.dispose();
    _weightController.dispose();
    _proteinController.dispose();
    _fatController.dispose();
    _carbsController.dispose();
    _imageUrlController.dispose();
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
        iconTheme: const IconThemeData(color: Color(0xFF2E3A2F)),
        title: const Text(
          '管理者上架',
          style: TextStyle(
            color: Color(0xFF2E3A2F),
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
          children: [
            _buildIntro(),
            const SizedBox(height: 16),
            _buildForm(),
            const SizedBox(height: 16),
            _buildDraftList(),
          ],
        ),
      ),
    );
  }

  Widget _buildIntro() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFF2F3E30),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '後台流程原型',
            style: TextStyle(color: Colors.white70, fontSize: 14),
          ),
          const SizedBox(height: 8),
          const Text(
            '店家可填寫餐點、營養與圖片資料',
            style: TextStyle(
              color: Colors.white,
              fontSize: 21,
              fontWeight: FontWeight.bold,
              height: 1.35,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            '目前先建立本機上架草稿，之後部署到學校雲端時可改為送出到 API 與 MySQL。',
            style: TextStyle(color: Colors.white70, height: 1.5),
          ),
          const SizedBox(height: 12),
          _buildMerchantPill(),
        ],
      ),
    );
  }

  Widget _buildMerchantPill() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withValues(alpha: 0.18)),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.verified_user_rounded,
            color: Colors.white,
            size: 18,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              '目前商家：${_merchant.businessName}',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildForm() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '新增商品',
            style: TextStyle(
              color: Color(0xFF2E3A2F),
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          _buildTextField(_nameController, '餐點名稱'),
          _buildStoreDropdown(),
          DropdownButtonFormField<String>(
            initialValue: _category,
            decoration: const InputDecoration(labelText: '餐點分類'),
            items: _categories
                .map(
                  (category) =>
                      DropdownMenuItem(value: category, child: Text(category)),
                )
                .toList(),
            onChanged: (value) {
              if (value == null) {
                return;
              }

              setState(() {
                _category = value;
              });
            },
          ),
          Row(
            children: [
              Expanded(child: _buildNumberField(_priceController, '價格')),
              const SizedBox(width: 10),
              Expanded(child: _buildNumberField(_stockController, '庫存')),
            ],
          ),
          _buildTextField(_tagsController, '標籤，以逗號分隔'),
          _buildTextField(_ingredientsController, '食材，以逗號分隔'),
          Row(
            children: [
              Expanded(child: _buildNumberField(_caloriesController, '熱量')),
              const SizedBox(width: 10),
              Expanded(child: _buildNumberField(_weightController, '重量g')),
            ],
          ),
          Row(
            children: [
              Expanded(child: _buildNumberField(_proteinController, '蛋白質g')),
              const SizedBox(width: 10),
              Expanded(child: _buildNumberField(_fatController, '脂肪g')),
              const SizedBox(width: 10),
              Expanded(child: _buildNumberField(_carbsController, '碳水g')),
            ],
          ),
          _buildTextField(_imageUrlController, '圖片網址'),
          const SizedBox(height: 12),
          const Text(
            '營業日',
            style: TextStyle(
              color: Color(0xFF2E3A2F),
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _weekdayOptions.entries
                .map(
                  (entry) => FilterChip(
                    label: Text(entry.value),
                    selected: _selectedWeekdays.contains(entry.key),
                    onSelected: (_) => _toggleWeekday(entry.key),
                  ),
                )
                .toList(),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: _submitDraft,
              icon: const Icon(Icons.add_business_rounded),
              label: const Text('建立上架草稿'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(labelText: label),
      ),
    );
  }

  Widget _buildStoreDropdown() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: DropdownButtonFormField<String>(
        initialValue: _storeName,
        decoration: const InputDecoration(
          labelText: '上架門市',
          helperText: '依商家帳戶權限顯示可管理門市',
        ),
        items: _merchant.allowedStoreNames
            .map((store) => DropdownMenuItem(value: store, child: Text(store)))
            .toList(),
        onChanged: (value) {
          if (value == null) {
            return;
          }

          setState(() {
            _storeName = value;
          });
        },
      ),
    );
  }

  Widget _buildNumberField(TextEditingController controller, String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: TextField(
        controller: controller,
        keyboardType: TextInputType.number,
        decoration: InputDecoration(labelText: label),
      ),
    );
  }

  Widget _buildDraftList() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '待上架商品',
          style: TextStyle(
            color: Color(0xFF2E3A2F),
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        if (_drafts.isEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
            ),
            child: const Text(
              '尚無上架草稿，建立後會顯示在這裡供管理者確認。',
              style: TextStyle(color: Colors.black54, height: 1.5),
            ),
          )
        else
          ..._drafts.map(_buildDraftTile),
      ],
    );
  }

  Widget _buildDraftTile(ProductListingDraft draft) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE5EDE2)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 58,
            height: 58,
            decoration: BoxDecoration(
              color: const Color(0xFFEAF5E8),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(Icons.image_rounded, color: Color(0xFF4E8D57)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  draft.name,
                  style: const TextStyle(
                    color: Color(0xFF2E3A2F),
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${draft.storeName} / ${draft.category} / ${draft.priceLabel}',
                  style: const TextStyle(fontSize: 13, color: Colors.black54),
                ),
                const SizedBox(height: 4),
                Text(
                  draft.nutritionLabel,
                  style: const TextStyle(fontSize: 13, color: Colors.black54),
                ),
                const SizedBox(height: 4),
                Text(
                  '${draft.weekdayLabel} / 庫存 ${draft.stockCount} 份',
                  style: const TextStyle(
                    fontSize: 13,
                    color: Color(0xFF4E8D57),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _toggleWeekday(int weekday) {
    setState(() {
      _selectedWeekdays.contains(weekday)
          ? _selectedWeekdays.remove(weekday)
          : _selectedWeekdays.add(weekday);
    });
  }

  void _submitDraft() {
    final draft = ProductListingDraft(
      name: _nameController.text.trim().isEmpty
          ? '未命名餐點'
          : _nameController.text.trim(),
      storeName: _storeName,
      category: _category,
      price: _parsePositiveInt(_priceController.text, 0),
      stockCount: _parsePositiveInt(_stockController.text, 1),
      tags: _splitValues(_tagsController.text),
      ingredients: _splitValues(_ingredientsController.text),
      calories: _parsePositiveInt(_caloriesController.text, 0),
      weightGrams: _parsePositiveInt(_weightController.text, 0),
      proteinGrams: _parsePositiveInt(_proteinController.text, 0),
      fatGrams: _parsePositiveInt(_fatController.text, 0),
      carbsGrams: _parsePositiveInt(_carbsController.text, 0),
      businessWeekdays: _selectedWeekdays.isEmpty
          ? const [DateTime.monday]
          : _selectedWeekdays.toList(),
      imageUrl: _imageUrlController.text.trim(),
    );

    setState(() {
      _drafts.insert(0, draft);
    });

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('已建立上架草稿')));
    _clearForm();
  }

  void _clearForm() {
    _nameController.clear();
    _priceController.clear();
    _stockController.clear();
    _tagsController.clear();
    _ingredientsController.clear();
    _caloriesController.clear();
    _weightController.clear();
    _proteinController.clear();
    _fatController.clear();
    _carbsController.clear();
    _imageUrlController.clear();
  }

  int _parsePositiveInt(String text, int fallback) {
    final value = int.tryParse(text.trim());
    if (value == null || value < 0) {
      return fallback;
    }

    return value;
  }

  List<String> _splitValues(String text) {
    return text
        .split(RegExp(r'[,，、]'))
        .map((value) => value.trim())
        .where((value) => value.isNotEmpty)
        .toList();
  }
}

const Map<int, String> _weekdayOptions = {
  DateTime.monday: '週一',
  DateTime.tuesday: '週二',
  DateTime.wednesday: '週三',
  DateTime.thursday: '週四',
  DateTime.friday: '週五',
  DateTime.saturday: '週六',
  DateTime.sunday: '週日',
};
