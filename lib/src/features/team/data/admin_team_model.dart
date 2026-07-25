class AdminTeamMemberModel {
  final String id;
  final String role; // super_admin, content_manager, finance_manager, support_agent, analyst
  final bool isActive;
  final String? lastLoginAt;
  final String createdAt;
  final Map<String, dynamic>? user;

  AdminTeamMemberModel({
    required this.id,
    required this.role,
    required this.isActive,
    this.lastLoginAt,
    required this.createdAt,
    this.user,
  });

  factory AdminTeamMemberModel.fromJson(Map<String, dynamic> json) {
    return AdminTeamMemberModel(
      id: json['id'] ?? '',
      role: json['role'] ?? '',
      isActive: json['is_active'] ?? true,
      lastLoginAt: json['last_login_at'],
      createdAt: json['created_at'] ?? '',
      user: json['users'] is Map<String, dynamic> ? json['users'] : null,
    );
  }

  String get userName => user?['full_name'] ?? 'Inconnu';
  String get userEmail => user?['email'] ?? '';
  String get userId => user?['id'] ?? '';

  String get roleLabel {
    switch (role) {
      case 'super_admin':
        return 'Super Admin';
      case 'content_manager':
        return 'Gestionnaire Contenu';
      case 'finance_manager':
        return 'Gestionnaire Finance';
      case 'support_agent':
        return 'Support';
      case 'analyst':
        return 'Analyste';
      default:
        return role;
    }
  }
}
