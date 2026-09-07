import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';

import '../../../../common/common.dart';
import '../data.dart';

part 'content_api.g.dart';

@RestApi()
abstract class ContentApi {
  factory ContentApi(Dio dio, {String baseUrl}) = _ContentApi;

  @GET('/admin/contents/{contentId}/payouts')
  Future<DataResponse<ContentPayoutSummary>> getPayoutsContent(@Path('contentId') String contentId);

  @GET('/admin/contents')
  Future<DataResponse<AdminContentModel>> getContents({
    @Query('search') String? search,
    @Query('status') String? status,
    @Query('type') String? type,
    @Query('page') required int page,
    @Query('limit') required int limit,
  });

  @POST('/admin/contents')
  @MultiPart()
  Future<DataResponse<AdminContentModel>> addContent(@Body() FormData body);

  @PUT('/admin/contents/{contentId}')
  Future<DataResponse<AdminContentModel>> updateContent(
    @Path('contentId') String id,
    @Body() FormData body,
  );

  @POST('/admin/contents/{contentId}/seasons')
  Future<DataResponse<AdminContentModel>> addSeason(@Path('contentId') String contentId, @Body() SeasonModel body);

  @POST('/admin/contents/seasons/{seasonId}/episodes')
  Future<DataResponse<AdminContentModel>> addEpisode(@Path('seasonId') String seasonId, @Body() EpisodeModel body);

  @PUT('/admin/contents/{contentId}/genres')
  Future<DataResponse<AdminContentModel>> updateGenresContent(@Path('contentId') String contentId, @Body() AdminContentModel body);

  @GET('/admin/contents/{contentId}')
  Future<DataResponse<AdminContentModel>> getContentDetail(@Path('contentId') String contentId);

  @GET('/admin/contents/{contentId}/videos')
  Future<DataResponse<ContentVideoModel>> getContentVideos(@Path('contentId') String contentId);

  @PATCH('/admin/contents/{contentId}/publish')
  Future<DataResponse<AdminContentModel>> publishContent(@Path('contentId') String contentId);

  @PATCH('/admin/contents/{contentId}/archive')
  Future<DataResponse<AdminContentModel>> archiveContent(@Path('contentId') String contentId);
}
