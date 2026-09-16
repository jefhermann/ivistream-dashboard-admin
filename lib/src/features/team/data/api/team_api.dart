import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';

import '../../../../common/common.dart';
import '../../team.dart';

part 'team_api.g.dart';

@RestApi()
abstract class AdminTeamApi {
  factory AdminTeamApi(Dio dio, {String baseUrl}) = _AdminTeamApi;

  @GET('/admin/team')
  Future<DataResponse<AdminMemberModel>> getMembers(@Query('q') String? query, @Query('page') int? page, @Query('limit') int? limit);

  @GET('/admin/team/invitations')
  Future<DataResponse<AdminInvitationModel>> getInvitations();

  @POST('/admin/team')
  Future<DataResponse<AdminMemberModel>> inviteMember(@Body() Map<String, dynamic> body);

  @PATCH('/admin/team/{id}')
  Future<DataResponse<AdminMemberModel>> updateMember(@Path('id') String id, @Body() Map<String, dynamic> body);

  @DELETE('/admin/team/{id}')
  Future<DataResponse<AdminMemberModel>> removeMember(@Path('id') String id);

  @DELETE('/admin/team/invitations/{id}')
  Future<DataResponse<AdminInvitationModel>> cancelInvitation(@Path('id') String id);
}