import 'package:dio/dio.dart';
import 'package:ivistream_dashboard_admin/src/common/common.dart';

import '../../content_gender.dart';

class ContentGenderRepository {
// On injecte l'API, pas Dio directement !
  final ContentGenderApi _api;

  ContentGenderRepository(this._api);

  Future<DataResponse<GenreModel>> getGenres({String? query, int? page}) async {
    try {
      final response = await _api.getGenres(query, page, 10);

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

  Future<bool> addGenres(GenreModel body) async {
    try {
      final response = await _api.addGenres(body);

      bool value = !response.hasError!;

      if (response.hasError == true) {
        throw Exception(response.message);
      }

      return value;
    } on DioException catch (e) {
      if (e.response != null && e.response!.data != null) {
        final message = e.response!.data['message'];
        throw Exception(message ?? "Une erreur inconnue est survenue");
      }
      throw Exception("Problème de connexion internet");
    }
  }

  Future<bool> updateGenre(String id,GenreModel body) async {
    try {
      final response = await _api.updateGenre(body, id);

      bool value = !response.hasError!;

      if (response.hasError == true) {
        throw Exception(response.message);
      }

      return value;
    } on DioException catch (e) {
      if (e.response != null && e.response!.data != null) {
        final message = e.response!.data['message'];
        throw Exception(message ?? "Une erreur inconnue est survenue");
      }
      throw Exception("Problème de connexion internet");
    }
  }
}
