import 'package:flutter/material.dart';
import 'package:my_app/models/food_item.dart';

class MockFoodRepository {
  static final DateTime _now = DateTime.now();

  static final List<FoodItem> allFoods = List.unmodifiable(
    List.generate(100, _buildFood),
  );

  static List<FoodItem> get recommendedPreview => allFoods.take(2).toList();

  static List<FoodItem> get expiringFoods {
    return allFoods.where((food) => food.isExpiringSoon).toList();
  }

  static FoodItem _buildFood(int index) {
    final templateIndex = index % _foodTemplates.length;
    final batchIndex = index ~/ _foodTemplates.length;
    final template = _foodTemplates[templateIndex];
    final store = _stores[(templateIndex * 7 + batchIndex) % _stores.length];
    final price = _priceTiers[index % _priceTiers.length];
    final distance = _distanceTiers[(index * 3) % _distanceTiers.length];
    final isExpiringSoon = index % 5 == 0;
    final stockCount = 3 + (index % 12);
    final suffix = _nameSuffixes[batchIndex % _nameSuffixes.length];
    final tags = _tagsWithExpiry(template.tags, isExpiringSoon);

    return FoodItem(
      id: 'food-${(index + 1).toString().padLeft(3, '0')}',
      name: '${template.name}$suffix',
      storeId: store.id,
      storeName: store.name,
      storeAddress: store.address,
      businessHours: store.businessHours,
      businessWeekdays: store.businessWeekdays,
      contactPhone: store.contactPhone,
      price: price,
      originalPrice: isExpiringSoon ? price + 30 : null,
      discountLabel: isExpiringSoon ? _discountLabels[index % 4] : null,
      category: template.category,
      tags: tags,
      ingredients: template.ingredients,
      nutritionTags: template.nutritionTags,
      distanceMeters: distance,
      stockCount: stockCount,
      expiresAt: isExpiringSoon
          ? _now.add(Duration(hours: 2 + (index % 5)))
          : null,
      isExpiringSoon: isExpiringSoon,
      ecoPriorityScore: isExpiringSoon
          ? 0.82 + ((index % 9) * 0.015)
          : 0.35 + ((index % 20) * 0.015),
      recommendationReason: _buildReason(tags, price, distance, isExpiringSoon),
      icon: template.icon,
    );
  }

  static List<String> _tagsWithExpiry(
    List<String> source,
    bool isExpiringSoon,
  ) {
    if (!isExpiringSoon) {
      return List.unmodifiable(source);
    }

    if (source.contains('即期優惠')) {
      return List.unmodifiable(source);
    }

    if (source.length < 3) {
      return List.unmodifiable([...source, '即期優惠']);
    }

    return List.unmodifiable([...source.take(2), '即期優惠']);
  }

  static String _buildReason(
    List<String> tags,
    int price,
    int distance,
    bool isExpiringSoon,
  ) {
    final preferenceText = tags.take(2).join('與');
    final distanceText = distance <= 800 ? '距離近' : '仍在可接受距離內';
    final budgetText = price <= 150 ? '符合常見預算' : '適合預算較高時選擇';

    if (isExpiringSoon) {
      return '$preferenceText，且為即期優惠商品，可協助減少浪費';
    }

    return '$preferenceText，$budgetText，$distanceText';
  }
}

class _FoodTemplate {
  const _FoodTemplate({
    required this.name,
    required this.category,
    required this.tags,
    required this.ingredients,
    required this.nutritionTags,
    required this.icon,
  });

  final String name;
  final String category;
  final List<String> tags;
  final List<String> ingredients;
  final List<String> nutritionTags;
  final IconData icon;
}

class _StoreTemplate {
  const _StoreTemplate({
    required this.id,
    required this.name,
    required this.address,
    required this.businessHours,
    required this.businessWeekdays,
    required this.contactPhone,
  });

  final String id;
  final String name;
  final String address;
  final String businessHours;
  final List<int> businessWeekdays;
  final String contactPhone;
}

const List<String> _nameSuffixes = ['', ' 經典', ' 主廚', ' 小份', ' 加量'];

const List<int> _priceTiers = [45, 60, 80, 100, 120, 140, 160, 180, 220, 260];

const List<int> _distanceTiers = [
  250,
  400,
  550,
  700,
  850,
  1000,
  1200,
  1500,
  1800,
  2200,
];

const List<String> _discountLabels = ['65折', '7折', '75折', '8折'];

const List<_FoodTemplate> _foodTemplates = [
  _FoodTemplate(
    name: '舒肥雞胸餐盒',
    category: '便當',
    tags: ['高蛋白', '低脂', '均衡'],
    ingredients: ['雞胸肉', '糙米', '花椰菜'],
    nutritionTags: ['高蛋白', '低脂'],
    icon: Icons.lunch_dining,
  ),
  _FoodTemplate(
    name: '蔬食藜麥便當',
    category: '便當',
    tags: ['素食', '高纖', '均衡'],
    ingredients: ['藜麥', '豆腐', '彩椒'],
    nutritionTags: ['高纖', '均衡'],
    icon: Icons.spa_rounded,
  ),
  _FoodTemplate(
    name: '鮭魚藜麥沙拉',
    category: '沙拉',
    tags: ['低脂', '均衡', '高蛋白'],
    ingredients: ['鮭魚', '藜麥', '生菜'],
    nutritionTags: ['低脂', '均衡'],
    icon: Icons.set_meal,
  ),
  _FoodTemplate(
    name: '鮮蝦酪梨沙拉',
    category: '沙拉',
    tags: ['低脂', '清爽', '高蛋白'],
    ingredients: ['鮮蝦', '酪梨', '蘿蔓生菜'],
    nutritionTags: ['低脂', '高蛋白'],
    icon: Icons.local_dining_rounded,
  ),
  _FoodTemplate(
    name: '日式豆腐和食',
    category: '和食',
    tags: ['素食', '均衡', '清爽'],
    ingredients: ['豆腐', '白飯', '海帶芽'],
    nutritionTags: ['均衡'],
    icon: Icons.rice_bowl,
  ),
  _FoodTemplate(
    name: '味噌鯖魚定食',
    category: '和食',
    tags: ['高蛋白', '均衡', '熱門'],
    ingredients: ['鯖魚', '味噌湯', '白飯'],
    nutritionTags: ['高蛋白', '均衡'],
    icon: Icons.rice_bowl_rounded,
  ),
  _FoodTemplate(
    name: '番茄雞肉義大利麵',
    category: '麵食',
    tags: ['高蛋白', '熱門', '均衡'],
    ingredients: ['雞肉', '番茄', '義大利麵'],
    nutritionTags: ['高蛋白'],
    icon: Icons.restaurant,
  ),
  _FoodTemplate(
    name: '香蒜菇菇義大利麵',
    category: '麵食',
    tags: ['素食', '清爽', '熱門'],
    ingredients: ['菇類', '蒜片', '義大利麵'],
    nutritionTags: ['均衡'],
    icon: Icons.restaurant_menu_rounded,
  ),
  _FoodTemplate(
    name: '鮪魚三明治',
    category: '早餐',
    tags: ['輕食', '高蛋白'],
    ingredients: ['鮪魚', '吐司', '生菜'],
    nutritionTags: ['輕食', '高蛋白'],
    icon: Icons.breakfast_dining,
  ),
  _FoodTemplate(
    name: '烤地瓜雞蛋盒',
    category: '早餐',
    tags: ['均衡', '高纖'],
    ingredients: ['地瓜', '水煮蛋', '毛豆'],
    nutritionTags: ['高纖', '均衡'],
    icon: Icons.egg_alt_rounded,
  ),
  _FoodTemplate(
    name: '水果優格杯',
    category: '甜點',
    tags: ['低脂', '輕食'],
    ingredients: ['優格', '香蕉', '莓果'],
    nutritionTags: ['低脂', '輕食'],
    icon: Icons.icecream,
  ),
  _FoodTemplate(
    name: '燕麥奶酪杯',
    category: '甜點',
    tags: ['低脂', '熱門'],
    ingredients: ['燕麥', '牛奶', '黑糖'],
    nutritionTags: ['低脂'],
    icon: Icons.cake_rounded,
  ),
  _FoodTemplate(
    name: '韓式泡菜雞肉飯',
    category: '韓式',
    tags: ['高蛋白', '微辣', '熱門'],
    ingredients: ['雞腿肉', '泡菜', '白飯'],
    nutritionTags: ['高蛋白'],
    icon: Icons.ramen_dining_rounded,
  ),
  _FoodTemplate(
    name: '韓式豆腐拌飯',
    category: '韓式',
    tags: ['素食', '微辣', '均衡'],
    ingredients: ['豆腐', '泡菜', '拌飯蔬菜'],
    nutritionTags: ['均衡'],
    icon: Icons.ramen_dining,
  ),
  _FoodTemplate(
    name: '南瓜濃湯套餐',
    category: '輕食',
    tags: ['清爽', '輕食', '均衡'],
    ingredients: ['南瓜', '牛奶', '全麥麵包'],
    nutritionTags: ['均衡'],
    icon: Icons.soup_kitchen_rounded,
  ),
  _FoodTemplate(
    name: '牛肉蔬菜捲',
    category: '輕食',
    tags: ['高蛋白', '輕食', '高纖'],
    ingredients: ['牛肉', '萵苣', '全麥餅皮'],
    nutritionTags: ['高蛋白', '高纖'],
    icon: Icons.wrap_text_rounded,
  ),
  _FoodTemplate(
    name: '墨西哥雞肉捲',
    category: '捲餅',
    tags: ['高蛋白', '微辣'],
    ingredients: ['雞肉', '莎莎醬', '餅皮'],
    nutritionTags: ['高蛋白'],
    icon: Icons.dinner_dining_rounded,
  ),
  _FoodTemplate(
    name: '彩蔬豆泥捲',
    category: '捲餅',
    tags: ['素食', '高纖'],
    ingredients: ['鷹嘴豆泥', '彩椒', '全麥餅皮'],
    nutritionTags: ['高纖'],
    icon: Icons.dining_rounded,
  ),
  _FoodTemplate(
    name: '藥膳雞湯',
    category: '湯品',
    tags: ['高蛋白', '清爽'],
    ingredients: ['雞腿', '枸杞', '藥膳湯底'],
    nutritionTags: ['高蛋白'],
    icon: Icons.soup_kitchen,
  ),
  _FoodTemplate(
    name: '番茄蔬菜湯',
    category: '湯品',
    tags: ['素食', '低脂', '清爽'],
    ingredients: ['番茄', '洋蔥', '高麗菜'],
    nutritionTags: ['低脂'],
    icon: Icons.local_cafe_rounded,
  ),
];

const List<_StoreTemplate> _stores = [
  _StoreTemplate(
    id: 'store-001',
    name: '健康餐盒店',
    address: '台北市中山區健康路 12 號',
    businessHours: '10:30-20:30',
    businessWeekdays: [
      DateTime.monday,
      DateTime.tuesday,
      DateTime.wednesday,
      DateTime.thursday,
      DateTime.friday,
    ],
    contactPhone: '02-2500-1200',
  ),
  _StoreTemplate(
    id: 'store-002',
    name: '原味沙拉吧',
    address: '台北市大安區青田街 8 號',
    businessHours: '11:00-19:30',
    businessWeekdays: [
      DateTime.monday,
      DateTime.tuesday,
      DateTime.wednesday,
      DateTime.thursday,
      DateTime.friday,
      DateTime.saturday,
      DateTime.sunday,
    ],
    contactPhone: '02-2700-0135',
  ),
  _StoreTemplate(
    id: 'store-003',
    name: '禾食堂',
    address: '台北市信義區松仁路 66 號',
    businessHours: '11:00-21:00',
    businessWeekdays: [
      DateTime.tuesday,
      DateTime.wednesday,
      DateTime.thursday,
      DateTime.friday,
      DateTime.saturday,
    ],
    contactPhone: '02-2720-0100',
  ),
  _StoreTemplate(
    id: 'store-004',
    name: '義式小館',
    address: '台北市中正區羅斯福路 120 號',
    businessHours: '11:30-21:30',
    businessWeekdays: [
      DateTime.wednesday,
      DateTime.thursday,
      DateTime.friday,
      DateTime.saturday,
      DateTime.sunday,
    ],
    contactPhone: '02-2360-0150',
  ),
  _StoreTemplate(
    id: 'store-005',
    name: '晨光早餐店',
    address: '台北市松山區民生東路 35 號',
    businessHours: '06:30-13:00',
    businessWeekdays: [DateTime.friday, DateTime.saturday, DateTime.sunday],
    contactPhone: '02-2710-0045',
  ),
  _StoreTemplate(
    id: 'store-006',
    name: '輕食專賣店',
    address: '台北市大同區承德路 58 號',
    businessHours: '09:00-18:00',
    businessWeekdays: [DateTime.monday, DateTime.wednesday, DateTime.friday],
    contactPhone: '02-2550-0060',
  ),
  _StoreTemplate(
    id: 'store-007',
    name: '綠意蔬食',
    address: '台北市大安區和平東路 88 號',
    businessHours: '10:30-20:00',
    businessWeekdays: [DateTime.tuesday, DateTime.thursday, DateTime.saturday],
    contactPhone: '02-2700-0088',
  ),
  _StoreTemplate(
    id: 'store-008',
    name: '首爾小食堂',
    address: '台北市萬華區成都路 22 號',
    businessHours: '11:00-21:30',
    businessWeekdays: [DateTime.saturday, DateTime.sunday],
    contactPhone: '02-2388-0220',
  ),
  _StoreTemplate(
    id: 'store-009',
    name: '暖食咖啡',
    address: '台北市中山區南京東路 45 號',
    businessHours: '08:00-18:00',
    businessWeekdays: [
      DateTime.monday,
      DateTime.tuesday,
      DateTime.wednesday,
      DateTime.thursday,
    ],
    contactPhone: '02-2508-0045',
  ),
  _StoreTemplate(
    id: 'store-010',
    name: '活力捲餅',
    address: '台北市松山區八德路 99 號',
    businessHours: '10:00-19:30',
    businessWeekdays: [
      DateTime.thursday,
      DateTime.friday,
      DateTime.saturday,
      DateTime.sunday,
    ],
    contactPhone: '02-2570-0099',
  ),
  _StoreTemplate(
    id: 'store-011',
    name: '巷口健康鋪',
    address: '台北市大同區迪化街 16 號',
    businessHours: '07:30-15:00',
    businessWeekdays: [
      DateTime.monday,
      DateTime.tuesday,
      DateTime.wednesday,
      DateTime.thursday,
      DateTime.friday,
    ],
    contactPhone: '02-2556-0016',
  ),
  _StoreTemplate(
    id: 'store-012',
    name: '城市沙拉',
    address: '台北市信義區松壽路 18 號',
    businessHours: '10:30-20:30',
    businessWeekdays: [
      DateTime.monday,
      DateTime.tuesday,
      DateTime.wednesday,
      DateTime.thursday,
      DateTime.friday,
      DateTime.saturday,
      DateTime.sunday,
    ],
    contactPhone: '02-2722-0018',
  ),
  _StoreTemplate(
    id: 'store-013',
    name: '巷弄義麵',
    address: '台北市大安區復興南路 66 號',
    businessHours: '11:30-22:00',
    businessWeekdays: [
      DateTime.tuesday,
      DateTime.wednesday,
      DateTime.thursday,
      DateTime.friday,
      DateTime.saturday,
    ],
    contactPhone: '02-2706-0066',
  ),
  _StoreTemplate(
    id: 'store-014',
    name: '米日食堂',
    address: '台北市中山區錦州街 21 號',
    businessHours: '11:00-20:30',
    businessWeekdays: [
      DateTime.wednesday,
      DateTime.thursday,
      DateTime.friday,
      DateTime.saturday,
      DateTime.sunday,
    ],
    contactPhone: '02-2521-0021',
  ),
  _StoreTemplate(
    id: 'store-015',
    name: '晴天早午餐',
    address: '台北市松山區光復北路 30 號',
    businessHours: '07:00-14:30',
    businessWeekdays: [DateTime.friday, DateTime.saturday, DateTime.sunday],
    contactPhone: '02-2760-0030',
  ),
  _StoreTemplate(
    id: 'store-016',
    name: '蔬醒廚房',
    address: '台北市文山區木柵路 46 號',
    businessHours: '10:00-19:00',
    businessWeekdays: [DateTime.monday, DateTime.wednesday, DateTime.friday],
    contactPhone: '02-2930-0046',
  ),
  _StoreTemplate(
    id: 'store-017',
    name: '辣味研究所',
    address: '台北市萬華區武昌街 57 號',
    businessHours: '12:00-22:00',
    businessWeekdays: [DateTime.tuesday, DateTime.thursday, DateTime.saturday],
    contactPhone: '02-2381-0057',
  ),
  _StoreTemplate(
    id: 'store-018',
    name: '週末湯屋',
    address: '台北市大安區信義路 155 號',
    businessHours: '11:00-19:00',
    businessWeekdays: [DateTime.saturday, DateTime.sunday],
    contactPhone: '02-2701-0155',
  ),
  _StoreTemplate(
    id: 'store-019',
    name: '木碗輕食',
    address: '台北市中正區杭州南路 19 號',
    businessHours: '08:30-17:30',
    businessWeekdays: [
      DateTime.monday,
      DateTime.tuesday,
      DateTime.wednesday,
      DateTime.thursday,
    ],
    contactPhone: '02-2390-0019',
  ),
  _StoreTemplate(
    id: 'store-020',
    name: '晚餐盒子',
    address: '台北市信義區忠孝東路 520 號',
    businessHours: '16:00-22:30',
    businessWeekdays: [
      DateTime.thursday,
      DateTime.friday,
      DateTime.saturday,
      DateTime.sunday,
    ],
    contactPhone: '02-2720-0520',
  ),
];
