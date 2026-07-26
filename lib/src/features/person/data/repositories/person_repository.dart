import 'package:dio/dio.dart';

import '../../../../common/common.dart';
import '../../person.dart';

class PersonRepository {
// On injecte l'API, pas Dio directement !
  final PersonApi _api;

  PersonRepository(this._api);

  Future<DataResponse<PersonModel>> getPersons({String? query, int? page}) async {
    try {
      final response = await _api.getPersons(query, page, 10);

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

  Future<bool> addPerson(PersonModel body) async {
    try {
      final response = await _api.addPerson(body);

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

  Future<bool> updatePerson(String id, PersonModel model) async {
    try {
      final response = await _api.updatePerson(model, id);

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
