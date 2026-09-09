class MerchantAccount {
  const MerchantAccount({
    required this.id,
    required this.businessName,
    required this.email,
    required this.contactPhone,
    required this.allowedStoreNames,
  });

  final String id;
  final String businessName;
  final String email;
  final String contactPhone;
  final List<String> allowedStoreNames;

  String get primaryStoreName {
    return allowedStoreNames.isEmpty ? businessName : allowedStoreNames.first;
  }

  MerchantAccount copyWith({
    String? id,
    String? businessName,
    String? email,
    String? contactPhone,
    List<String>? allowedStoreNames,
  }) {
    return MerchantAccount(
      id: id ?? this.id,
      businessName: businessName ?? this.businessName,
      email: email ?? this.email,
      contactPhone: contactPhone ?? this.contactPhone,
      allowedStoreNames: allowedStoreNames ?? this.allowedStoreNames,
    );
  }

  static const demo = MerchantAccount(
    id: 'merchant-demo',
    businessName: '銘傳校園示範商家',
    email: 'store@mcu-food.local',
    contactPhone: '03-350-7001',
    allowedStoreNames: ['全家龜山銘美店', '7-11 龜山銘傳門市'],
  );
}
