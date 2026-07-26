import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';

import '../../../../common/common.dart';
import '../../country.dart';

// Génération de code pour Retrofit
part 'country_api.g.dart';

@RestApi()
abstract class CountryApi {
  factory CountryApi(Dio dio, {String baseUrl}) = _CountryApi;

  @GET("/admin/countries")
  Future<DataResponse<CountryModel>> getCountries(@Query('q') String? query, @Query('page') int? page, @Query('limit') int? limit);

  @POST("/admin/countries")
  Future<DataResponse<CountryModel>> createCountry(@Body() CountryModel country);

  @PUT('/admin/countries/{code}')
  Future<DataResponse<CountryModel>> updateCountry(@Body() CountryModel? body, @Path('code') String code);
}
