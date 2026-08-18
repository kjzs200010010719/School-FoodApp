class UserPreference {
  const UserPreference({
    required this.dietaryPreferences,
    required this.budgetMin,
    required this.budgetMax,
    required this.distanceLimitMeters,
    required this.preferredTags,
    required this.avoidIngredients,
    required this.wasteReductionEnabled,
  });

  final List<String> dietaryPreferences;
  final int budgetMin;
  final int budgetMax;
  final int distanceLimitMeters;
  final List<String> preferredTags;
  final List<String> avoidIngredients;
  final bool wasteReductionEnabled;

  static const defaultPreference = UserPreference(
    dietaryPreferences: ['高蛋白', '均衡'],
    budgetMin: 0,
    budgetMax: 150,
    distanceLimitMeters: 1000,
    preferredTags: ['高蛋白', '低脂', '均衡', '即期優惠'],
    avoidIngredients: [],
    wasteReductionEnabled: true,
  );
}
