enum UserRole { farmer, buyer, admin }

class UserProfile {
  final String id;
  final String name;
  final String phone;
  final UserRole role;
  final String village;
  final String taluka;
  final String district;
  final String language; // 'en', 'hi', 'mr'
  final bool contactEnabled;
  final bool isVerifiedSeller;
  final DateTime createdAt;

  UserProfile({
    required this.id,
    required this.name,
    required this.phone,
    required this.role,
    required this.village,
    required this.taluka,
    required this.district,
    this.language = 'en',
    this.contactEnabled = true,
    this.isVerifiedSeller = true,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  String get locationString {
    if (village.isNotEmpty && district.isNotEmpty) {
      return "$village, $taluka ($district)";
    } else if (district.isNotEmpty) {
      return district;
    }
    return "Maharashtra";
  }

  UserProfile copyWith({
    String? name,
    String? phone,
    UserRole? role,
    String? village,
    String? taluka,
    String? district,
    String? language,
    bool? contactEnabled,
    bool? isVerifiedSeller,
  }) {
    return UserProfile(
      id: id,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      role: role ?? this.role,
      village: village ?? this.village,
      taluka: taluka ?? this.taluka,
      district: district ?? this.district,
      language: language ?? this.language,
      contactEnabled: contactEnabled ?? this.contactEnabled,
      isVerifiedSeller: isVerifiedSeller ?? this.isVerifiedSeller,
      createdAt: createdAt,
    );
  }
}
