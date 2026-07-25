import 'package:dio/dio.dart';

import '../../country.dart';

class CountryRepository {
// On injecte l'API, pas Dio directement !
  final CountryApi _api;

  CountryRepository(this._api);

  Future<List<CountryModel>> getCountries(String? search) async {
    try {
      final response = await _api.getCountries(search);

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

  Future<CountryModel?> addCountry(CountryModel country) async {
    try {
      final response = await _api.createCountry(country);

      if (response.hasError == true) {
        throw Exception(response.message);
      }

      return response.item;

    } on DioException catch (e) {
      if (e.response != null && e.response!.data != null) {
        final message = e.response!.data['message'];
        throw Exception(message ?? "Une erreur inconnue est survenue");
      }
      throw Exception("Problème de connexion internet");
    }
  }
}
