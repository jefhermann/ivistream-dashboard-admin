import 'package:dio/dio.dart';

import '../../person.dart';

class PersonRepository {
// On injecte l'API, pas Dio directement !
  final PersonApi _api;

  PersonRepository(this._api);

  Future<List<PersonModel>> getPersons({String? query}) async {
    try {
      final response = await _api.getPersons(query);

      if (response.hasError == true) {
        throw Exception(response.message);
      }

      return response.items ?? [];
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
}
