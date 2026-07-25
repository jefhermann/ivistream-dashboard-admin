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
  Future<DataResponse<PersonModel>> getPersons(@Query('q') String? query);

  @POST('/admin/persons')
  Future<DataResponse<PersonModel>> addPerson(@Body() PersonModel? body);
}
