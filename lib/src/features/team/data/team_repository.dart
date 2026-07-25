import 'package:dio/dio.dart';

import 'admin_team_model.dart';

class TeamRepository {
  final Dio _dio;

  TeamRepository(this._dio);

  Future<List<AdminTeamMemberModel>> getTeam() async {
    final response = await _dio.get('/admin/team');
    final items = response.data['items'] as List? ?? [];
    return items.map((j) => AdminTeamMemberModel.fromJson(j)).toList();
  }

  Future<void> addMember(String userId, String role) async {
    await _dio.post('/admin/team', data: {
      'userId': userId,
      'role': role,
    });
  }

  Future<void> updateMember(String adminId, {String? role, bool? isActive}) async {
    final data = <String, dynamic>{};
    if (role != null) data['role'] = role;
    if (isActive != null) data['isActive'] = isActive;
    await _dio.patch('/admin/team/$adminId', data: data);
  }

  Future<void> removeMember(String adminId) async {
    await _dio.delete('/admin/team/$adminId');
  }
}
