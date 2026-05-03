import 'package:dio/dio.dart';

import '../../../common/common.dart';
import 'admin_stats_model.dart';
import 'dashboard_api.dart';

class DashboardRepository {
  final DashboardApi _api;

  DashboardRepository(this._api);

  Future<DataResponse<AdminStatsModel>> getStats() async {
    try {
      return await _api.getStats();
    } on DioException catch (e) {
      if (e.response != null && e.response!.data != null) {
        final message = e.response!.data['message'];
        return DataResponse.failure(message ?? "Erreur serveur");
      }
      return DataResponse.failure("Problème de connexion");
    }
  }

  Future<DataResponse<RecentUserModel>> getRecentUsers() async {
    try {
      return await _api.getRecentUsers(page: 1, limit: 5);
    } on DioException catch (e) {
      if (e.response != null && e.response!.data != null) {
        final message = e.response!.data['message'];
        return DataResponse.failure(message ?? "Erreur serveur");
      }
      return DataResponse.failure("Problème de connexion");
    }
  }

  Future<DataResponse<RecentContentModel>> getRecentContents() async {
    try {
      return await _api.getRecentContents(page: 1, limit: 5);
    } on DioException catch (e) {
      if (e.response != null && e.response!.data != null) {
        final message = e.response!.data['message'];
        return DataResponse.failure(message ?? "Erreur serveur");
      }
      return DataResponse.failure("Problème de connexion");
    }
  }
}
