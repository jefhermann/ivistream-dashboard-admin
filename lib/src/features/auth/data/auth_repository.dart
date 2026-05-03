import 'package:dio/dio.dart';

import '../../../common/common.dart';
import 'admin_info_model.dart';
import 'auth_api.dart';

class AuthRepository {
  final AuthApi _api;

  AuthRepository(this._api);

  Future<DataResponse<AdminInfoModel>> login(String email, String password) async {
    try {
      final response = await _api.login(UserModel(email: email, password: password));

      if (response.hasError == true) {
        throw Exception(response.message);
      }

      await SharedPreferencesService.saveToken(response.item?.accessToken ?? "");
      await SharedPreferencesService.saveRefreshToken(response.item?.refreshToken ?? "");

      return await getUserInfos();
    } on DioException catch (e) {
      if (e.response != null && e.response!.data != null) {
        final message = e.response!.data['message'];
        throw Exception(message ?? "Une erreur inconnue est survenue");
      }
      throw Exception("Problème de connexion internet");
    }
  }

  Future<DataResponse<AdminInfoModel>> getUserInfos() async {
    try {
      final response = await _api.profile();

      if (response.hasError == true) {
        throw Exception(response.message);
      }

      return response;
    } on DioException catch (e) {
      if (e.response != null && e.response!.data != null) {
        final message = e.response!.data['message'];
        throw Exception(message ?? "Une erreur inconnue est survenue");
      }
      throw Exception("Problème de connexion internet");
    }
  }
}
