import 'package:dio/dio.dart';

import '../../../common/common.dart';
import '../team.dart';


class AdminTeamRepository {
  final AdminTeamApi _api;

  AdminTeamRepository(this._api);

  Future<DataResponse<AdminMemberModel>> getMembers({String? query, int? page}) async {
    try {
      final response = await _api.getMembers(query, page, 10);

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

  Future<List<AdminInvitationModel>> getInvitations() async {
    try {
      final response = await _api.getInvitations();

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

  Future<AdminMemberModel?> inviteMember({required String email, required AdminRole role}) async {
    try {
      final response = await _api.inviteMember({'email': email, 'role': role.apiValue});

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

  Future<bool?> updateMember(String memberId, {AdminRole? role, bool? isActive}) async {
    try {
      final body = <String, dynamic>{
        if (role != null) 'role': role.apiValue,
        if (isActive != null) 'isActive': isActive,
      };

      final response = await _api.updateMember(memberId, body);

      if (response.hasError == true) {
        throw Exception(response.message);
      }

      return response.hasError;
    } on DioException catch (e) {
      if (e.response != null && e.response!.data != null) {
        final message = e.response!.data['message'];
        throw Exception(message ?? "Une erreur inconnue est survenue");
      }
      throw Exception("Problème de connexion internet");
    }
  }

  Future<bool?> removeMember(String memberId) async {
    try {
      final response = await _api.removeMember(memberId);

      if (response.hasError == true) {
        throw Exception(response.message);
      }

      return response.hasError;
    } on DioException catch (e) {
      if (e.response != null && e.response!.data != null) {
        final message = e.response!.data['message'];
        throw Exception(message ?? "Une erreur inconnue est survenue");
      }
      throw Exception("Problème de connexion internet");
    }
  }

  Future<bool?> cancelInvitation(String invitationId) async {
    try {
      final response = await _api.cancelInvitation(invitationId);

      if (response.hasError == true) {
        throw Exception(response.message);
      }

      return response.hasError;
    } on DioException catch (e) {
      if (e.response != null && e.response!.data != null) {
        final message = e.response!.data['message'];
        throw Exception(message ?? "Une erreur inconnue est survenue");
      }
      throw Exception("Problème de connexion internet");
    }
  }
}