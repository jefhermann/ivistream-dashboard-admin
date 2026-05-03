class AdminProducerModel {
  final String id;
  final String name;
  final String slug;
  final String? description;
  final String? countryCode;
  final String? logoUrl;
  final bool isVerified;
  final String createdAt;

  // Detail fields
  final int? contentsCount;
  final List<ProducerMemberModel>? members;

  AdminProducerModel({
    required this.id,
    required this.name,
    required this.slug,
    this.description,
    this.countryCode,
    this.logoUrl,
    required this.isVerified,
    required this.createdAt,
    this.contentsCount,
    this.members,
  });

  factory AdminProducerModel.fromJson(Map<String, dynamic> json) {
    return AdminProducerModel(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      slug: json['slug'] ?? '',
      description: json['description'],
      countryCode: json['country_code'],
      logoUrl: json['logo_url'],
      isVerified: json['is_verified'] ?? false,
      createdAt: json['created_at'] ?? '',
      contentsCount: json['contents_count'],
      members: json['members'] != null
          ? (json['members'] as List).map((m) => ProducerMemberModel.fromJson(m)).toList()
          : null,
    );
  }
}

class ProducerMemberModel {
  final String id;
  final String role;
  final bool isActive;
  final Map<String, dynamic>? user;

  ProducerMemberModel({
    required this.id,
    required this.role,
    required this.isActive,
    this.user,
  });

  factory ProducerMemberModel.fromJson(Map<String, dynamic> json) {
    return ProducerMemberModel(
      id: json['id'] ?? '',
      role: json['role'] ?? '',
      isActive: json['is_active'] ?? true,
      user: json['users'] is Map<String, dynamic> ? json['users'] : null,
    );
  }

  String get userName => user?['full_name'] ?? 'Inconnu';
  String get userEmail => user?['email'] ?? '';

  String get roleLabel {
    switch (role) {
      case 'owner':
        return 'Propriétaire';
      case 'manager':
        return 'Manager';
      case 'comptable':
        return 'Comptable';
      case 'viewer':
        return 'Lecteur';
      default:
        return role;
    }
  }
}
