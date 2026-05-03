class AdminUserModel {
  final String id;
  final String email;
  final String? fullName;
  final String? phone;
  final String? countryCode;
  final bool isActive;
  final bool emailVerified;
  final String? trialStatus; // available, active, expired, converted
  final String? trialStartedAt;
  final String? trialEndsAt;
  final int? trialDurationDays;
  final String createdAt;
  final String? lastSignInAt;

  // Detail fields
  final List<UserProfileModel>? profiles;
  final UserSubscriptionModel? subscription;
  final int? paymentsCount;

  AdminUserModel({
    required this.id,
    required this.email,
    this.fullName,
    this.phone,
    this.countryCode,
    required this.isActive,
    required this.emailVerified,
    this.trialStatus,
    this.trialStartedAt,
    this.trialEndsAt,
    this.trialDurationDays,
    required this.createdAt,
    this.lastSignInAt,
    this.profiles,
    this.subscription,
    this.paymentsCount,
  });

  factory AdminUserModel.fromJson(Map<String, dynamic> json) {
    return AdminUserModel(
      id: json['id'] ?? '',
      email: json['email'] ?? '',
      fullName: json['full_name'],
      phone: json['phone'],
      countryCode: json['country_code'],
      isActive: json['is_active'] ?? true,
      emailVerified: json['email_verified'] ?? false,
      trialStatus: json['trial_status'],
      trialStartedAt: json['trial_started_at'],
      trialEndsAt: json['trial_ends_at'],
      trialDurationDays: json['trial_duration_days'],
      createdAt: json['created_at'] ?? '',
      lastSignInAt: json['last_sign_in_at'],
      profiles: json['profiles'] != null
          ? (json['profiles'] as List).map((p) => UserProfileModel.fromJson(p)).toList()
          : null,
      subscription: json['subscription'] != null
          ? UserSubscriptionModel.fromJson(json['subscription'])
          : null,
      paymentsCount: json['payments_count'],
    );
  }

  String get trialStatusLabel {
    switch (trialStatus) {
      case 'available':
        return 'Disponible';
      case 'active':
        return 'En cours';
      case 'expired':
        return 'Expiré';
      case 'converted':
        return 'Converti';
      default:
        return trialStatus ?? 'N/A';
    }
  }
}

class UserProfileModel {
  final String id;
  final String name;
  final bool isChild;
  final bool isPrimary;

  UserProfileModel({
    required this.id,
    required this.name,
    required this.isChild,
    required this.isPrimary,
  });

  factory UserProfileModel.fromJson(Map<String, dynamic> json) {
    return UserProfileModel(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      isChild: json['is_child'] ?? false,
      isPrimary: json['is_primary'] ?? false,
    );
  }
}

class UserSubscriptionModel {
  final String id;
  final String status;
  final String? expiresAt;
  final Map<String, dynamic>? plan;

  UserSubscriptionModel({
    required this.id,
    required this.status,
    this.expiresAt,
    this.plan,
  });

  factory UserSubscriptionModel.fromJson(Map<String, dynamic> json) {
    return UserSubscriptionModel(
      id: json['id'] ?? '',
      status: json['status'] ?? '',
      expiresAt: json['expires_at'],
      plan: json['plans'] is Map<String, dynamic> ? json['plans'] : null,
    );
  }

  String get planName => plan?['name'] ?? 'Inconnu';
  String get planType => plan?['type'] ?? '';
}

class PaginationModel {
  final int page;
  final int limit;
  final int total;
  final int totalPages;

  PaginationModel({
    required this.page,
    required this.limit,
    required this.total,
    required this.totalPages,
  });

  factory PaginationModel.fromJson(Map<String, dynamic> json) {
    return PaginationModel(
      page: json['page'] ?? 1,
      limit: json['limit'] ?? 20,
      total: json['total'] ?? 0,
      totalPages: json['totalPages'] ?? 0,
    );
  }
}
