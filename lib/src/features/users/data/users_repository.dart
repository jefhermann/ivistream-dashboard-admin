import 'package:dio/dio.dart';

import 'admin_user_model.dart';

class UsersRepository {
  final Dio _dio;

  UsersRepository(this._dio);

  /// Liste des utilisateurs avec pagination, recherche et filtres
  Future<({List<AdminUserModel> users, PaginationModel pagination})> getUsers({
    int page = 1,
    int limit = 20,
    String? search,
    String? status,
    String? trialStatus,
  }) async {
    final queryParams = <String, dynamic>{
      'page': page,
      'limit': limit,
    };
    if (search != null && search.isNotEmpty) queryParams['search'] = search;
    if (status != null && status.isNotEmpty) queryParams['status'] = status;
    if (trialStatus != null && trialStatus.isNotEmpty) queryParams['trial_status'] = trialStatus;

    final response = await _dio.get('/admin/users', queryParameters: queryParams);
    final data = response.data;

    final users = (data['items'] as List? ?? [])
        .map((json) => AdminUserModel.fromJson(json))
        .toList();

    final pagination = PaginationModel.fromJson(data['pagination'] ?? {});

    return (users: users, pagination: pagination);
  }

  /// Détail d'un utilisateur
  Future<AdminUserModel> getUserDetail(String userId) async {
    final response = await _dio.get('/admin/users/$userId');
    final data = response.data;

    return AdminUserModel.fromJson(data['item']);
  }

  /// Activer / Désactiver un utilisateur
  Future<void> toggleUserStatus(String userId, bool isActive) async {
    await _dio.patch('/admin/users/$userId/status', data: {
      'isActive': isActive,
    });
  }

  /// Prolonger l'essai
  Future<void> extendTrial(String userId, int trialDays) async {
    await _dio.patch('/admin/users/$userId/trial', data: {
      'trialDays': trialDays,
    });
  }
}
