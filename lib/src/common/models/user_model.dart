class UserModel {
  String? id;
  String? email;
  String? fullName;
  String? password;
  String? role; // super_admin, content_manager, finance_manager, support_agent, analyst

  UserModel({this.id, this.email, this.fullName, this.password, this.role});

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] ?? '',
      email: json['email'] ?? '',
      fullName: json['full_name'] ?? '',
      role: json['role'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (id != null) data['id'] = id;
    if (email != null) data['email'] = email;
    if (fullName != null) data['full_name'] = fullName;
    if (password != null) data['password'] = password;
    if (role != null) data['role'] = role;
    return data;
  }

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
        return role ?? 'Inconnu';
    }
  }
}
