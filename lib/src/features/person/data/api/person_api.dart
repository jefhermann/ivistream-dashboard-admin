import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';

import '../../../../common/common.dart';
import '../../person.dart';

// Génération de code pour Retrofit
part 'person_api.g.dart';

@RestApi()
abstract class PersonApi {
  factory PersonApi(Dio dio, {String baseUrl}) = _PersonApi;

  @GET('/admin/persons')
  Future<DataResponse<PersonModel>> getPersons(@Query('q') String? query, @Query('page') int? page, @Query('limit') int? limit);

  @POST('/admin/persons')
  Future<DataResponse<PersonModel>> addPerson(@Body() PersonModel? body);

  @PUT('/admin/persons/{id}')
  Future<DataResponse<PersonModel>> updatePerson(@Body() PersonModel? body, @Path('id') String id);
}
