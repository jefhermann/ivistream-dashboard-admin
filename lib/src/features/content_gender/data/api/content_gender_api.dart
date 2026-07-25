import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';

import '../../../../common/common.dart';
import '../../content_gender.dart';

// Génération de code pour Retrofit
part 'content_gender_api.g.dart';

@RestApi()
abstract class ContentGenderApi {
  factory ContentGenderApi(Dio dio, {String baseUrl}) = _ContentGenderApi;

  @GET('/admin/genres')
  Future<DataResponse<GenreModel>> getGenres(@Query('q') String? query);

  @POST('/admin/genres')
  Future<DataResponse<GenreModel>> addGenres(@Body() GenreModel? body);
}
