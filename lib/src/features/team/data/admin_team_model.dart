enum AdminRole {
  superAdmin,
  contentManager,
  financeManager,
  supportAgent,
  analyst;

  static AdminRole fromApi(String? value) {
    switch (value) {
      case 'super_admin':
        return AdminRole.superAdmin;
      case 'content_manager':
        return AdminRole.contentManager;
      case 'finance_manager':
        return AdminRole.financeManager;
      case 'support_agent':
        return AdminRole.supportAgent;
      case 'analyst':
      default:
        return AdminRole.analyst;
    }
  }

  String get apiValue {
    switch (this) {
      case AdminRole.superAdmin:
        return 'super_admin';
      case AdminRole.contentManager:
        return 'content_manager';
      case AdminRole.financeManager:
        return 'finance_manager';
      case AdminRole.supportAgent:
        return 'support_agent';
      case AdminRole.analyst:
        return 'analyst';
    }
  }

  String get label {
    switch (this) {
      case AdminRole.superAdmin:
        return 'Super Admin';
      case AdminRole.contentManager:
        return 'Gestionnaire de contenu';
      case AdminRole.financeManager:
        return 'Gestionnaire financier';
      case AdminRole.supportAgent:
        return 'Agent support';
      case AdminRole.analyst:
        return 'Analyste';
    }
  }
}

class AdminMemberModel {
  final String id;
  final String userId;
  final String email;
  final String fullName;
  final AdminRole role;
  final bool isActive;
  final DateTime? lastLoginAt;
  final DateTime createdAt;

  AdminMemberModel({
    required this.id,
    required this.userId,
    required this.email,
    required this.fullName,
    required this.role,
    required this.isActive,
    this.lastLoginAt,
    required this.createdAt,
  });

  factory AdminMemberModel.fromJson(Map<String, dynamic> json) {
    final user = json['users'] is Map<String, dynamic> ? json['users'] as Map<String, dynamic> : null;
    return AdminMemberModel(
      id: json['id']?.toString() ?? '',
      userId: user?['id']?.toString() ?? '',
      email: user?['email']?.toString() ?? '',
      fullName: user?['full_name']?.toString() ?? '',
      role: AdminRole.fromApi(json['role']),
      isActive: json['is_active'] ?? true,
      lastLoginAt: json['last_login_at'] != null ? DateTime.tryParse(json['last_login_at']) : null,
      createdAt: DateTime.tryParse(json['created_at']?.toString() ?? '') ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      if (createdAt != null) 'created_at': createdAt,
    };
  }
}

class AdminInvitationModel {
  final String id;
  final String email;
  final AdminRole role;
  final String status;
  final DateTime expiresAt;
  final DateTime createdAt;
  final String? invitedByName;

  AdminInvitationModel({
    required this.id,
    required this.email,
    required this.role,
    required this.status,
    required this.expiresAt,
    required this.createdAt,
    this.invitedByName,
  });

  factory AdminInvitationModel.fromJson(Map<String, dynamic> json) {
    final inviter = json['users'] is Map<String, dynamic> ? json['users'] as Map<String, dynamic> : null;
    return AdminInvitationModel(
      id: json['id']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      role: AdminRole.fromApi(json['role']),
      status: json['status']?.toString() ?? 'pending',
      expiresAt: DateTime.tryParse(json['expires_at']?.toString() ?? '') ?? DateTime.now(),
      createdAt: DateTime.tryParse(json['created_at']?.toString() ?? '') ?? DateTime.now(),
      invitedByName: inviter?['full_name']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      if (status != null) 'status': status,
      if (createdAt != null) 'created_at': createdAt,
    };
  }

  bool get isExpired => DateTime.now().isAfter(expiresAt);
}