import 'package:dio/dio.dart';
import 'package:ivistream_dashboard_admin/src/common/common.dart';
import 'package:retrofit/retrofit.dart';

import 'admin_stats_model.dart';

part 'dashboard_api.g.dart';

@RestApi()
abstract class DashboardApi {
  factory DashboardApi(Dio dio, {String baseUrl}) = _DashboardApi;

  @GET("/admin/stats")
  Future<DataResponse<AdminStatsModel>> getStats();

  @GET("/admin/users")
  Future<DataResponse<RecentUserModel>> getRecentUsers({
    @Query("page") int page = 1,
    @Query("limit") int limit = 5,
  });

  @GET("/admin/contents")
  Future<DataResponse<RecentContentModel>> getRecentContents({
    @Query("page") int page = 1,
    @Query("limit") int limit = 5,
  });
}
