class UserProfile {
  const UserProfile({
    required this.name,
    required this.email,
    required this.phone,
    required this.dietaryTags,
    required this.budgetMax,
    required this.distanceLimitMeters,
  });

  final String name;
  final String email;
  final String phone;
  final List<String> dietaryTags;
  final int budgetMax;
  final int distanceLimitMeters;

  UserProfile copyWith({
    String? name,
    String? email,
    String? phone,
    List<String>? dietaryTags,
    int? budgetMax,
    int? distanceLimitMeters,
  }) {
    return UserProfile(
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      dietaryTags: dietaryTags ?? this.dietaryTags,
      budgetMax: budgetMax ?? this.budgetMax,
      distanceLimitMeters: distanceLimitMeters ?? this.distanceLimitMeters,
    );
  }

  static const demo = UserProfile(
    name: '測試使用者',
    email: 'demo@foodapp.local',
    phone: '0912-345-678',
    dietaryTags: ['高蛋白', '低脂', '均衡'],
    budgetMax: 150,
    distanceLimitMeters: 1000,
  );
}
