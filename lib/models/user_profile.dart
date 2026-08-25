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
  final int? budgetMax;
  final int? distanceLimitMeters;

  UserProfile copyWith({
    String? name,
    String? email,
    String? phone,
    List<String>? dietaryTags,
    int? budgetMax,
    int? distanceLimitMeters,
    bool clearBudgetMax = false,
    bool clearDistanceLimit = false,
  }) {
    return UserProfile(
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      dietaryTags: dietaryTags ?? this.dietaryTags,
      budgetMax: clearBudgetMax ? null : budgetMax ?? this.budgetMax,
      distanceLimitMeters: clearDistanceLimit
          ? null
          : distanceLimitMeters ?? this.distanceLimitMeters,
    );
  }

  Map<String, Object?> toJson() {
    return {
      'name': name,
      'email': email,
      'phone': phone,
      'dietaryTags': dietaryTags,
      'budgetMax': budgetMax,
      'distanceLimitMeters': distanceLimitMeters,
    };
  }

  factory UserProfile.fromJson(Map<String, Object?> json) {
    return UserProfile(
      name: json['name'] as String? ?? demo.name,
      email: json['email'] as String? ?? demo.email,
      phone: json['phone'] as String? ?? demo.phone,
      dietaryTags:
          (json['dietaryTags'] as List?)?.whereType<String>().toList() ??
          demo.dietaryTags,
      budgetMax: json['budgetMax'] as int?,
      distanceLimitMeters: json['distanceLimitMeters'] as int?,
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
