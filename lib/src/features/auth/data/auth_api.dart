import 'package:dio/dio.dart';
import 'package:ivistream_dashboard_admin/src/common/common.dart';
import 'package:retrofit/retrofit.dart';

import '../data/admin_info_model.dart';

part 'auth_api.g.dart';

@RestApi()
abstract class AuthApi {
  factory AuthApi(Dio dio, {String baseUrl}) = _AuthApi;

  @POST("/admin/login")
  Future<DataResponse<TokenModel>> login(@Body() UserModel user);

  @POST("/admin/logout")
  Future<DataResponse<TokenModel>> logout();

  @GET("/admin/me")
  Future<DataResponse<AdminInfoModel>> profile();
}
