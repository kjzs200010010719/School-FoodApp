class ProductListingDraft {
  const ProductListingDraft({
    required this.name,
    required this.storeName,
    required this.category,
    required this.price,
    required this.stockCount,
    required this.tags,
    required this.ingredients,
    required this.calories,
    required this.weightGrams,
    required this.proteinGrams,
    required this.fatGrams,
    required this.carbsGrams,
    required this.businessWeekdays,
    required this.imageUrl,
  });

  final String name;
  final String storeName;
  final String category;
  final int price;
  final int stockCount;
  final List<String> tags;
  final List<String> ingredients;
  final int calories;
  final int weightGrams;
  final int proteinGrams;
  final int fatGrams;
  final int carbsGrams;
  final List<int> businessWeekdays;
  final String imageUrl;

  String get priceLabel => 'NT\$ $price';

  String get nutritionLabel =>
      '$calories kcal / ${weightGrams}g / P$proteinGrams F$fatGrams C$carbsGrams';

  String get weekdayLabel {
    if (businessWeekdays.length == 7) {
      return '每日營業';
    }

    const labels = {
      DateTime.monday: '週一',
      DateTime.tuesday: '週二',
      DateTime.wednesday: '週三',
      DateTime.thursday: '週四',
      DateTime.friday: '週五',
      DateTime.saturday: '週六',
      DateTime.sunday: '週日',
    };

    final sortedWeekdays = [...businessWeekdays]..sort();
    return sortedWeekdays
        .map((weekday) => labels[weekday])
        .whereType<String>()
        .join('、');
  }
}
