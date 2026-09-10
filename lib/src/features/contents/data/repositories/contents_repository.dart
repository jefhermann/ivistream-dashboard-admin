import 'package:dio/dio.dart';

import '../../../../common/common.dart';
import '../api/api.dart';
import '../models/models.dart';

class ContentsRepository {
  final ContentApi _api;

  ContentsRepository(this._api);

  Future<({List<AdminContentModel>? contents, PaginationModel? pagination})> getContents({
    int page = 1,
    int limit = 20,
    String? search,
    String? status,
    String? type,
  }) async {
    try {
      final response = await _api.getContents(page: page, limit: limit, search: search, status: status, type: type);

      if (response.hasError == true) {
        throw Exception(response.message);
      }

      return (contents: response.items, pagination: response.pagination);
    } on DioException catch (e) {
      if (e.response != null && e.response!.data != null) {
        final message = e.response!.data['message'];
        throw Exception(message ?? "Une erreur inconnue est survenue");
      }
      throw Exception("Problème de connexion internet");
    }
  }

  Future<AdminContentModel?> getContentDetail(String contentId) async {
    try {
      final response = await _api.getContentDetail(contentId);

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

  Future<List<ContentVideoModel>> getContentVideos(String contentId) async {
    try {
      final response = await _api.getContentVideos(contentId);

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

  Future<List<SeasonModel>> getContentSeasonVideos(String contentId) async {
    try {
      final response = await _api.getContentSeasonVideos(contentId);

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

  Future<StatContentModel?> getContentStats(String contentId) async {
    try {
      final response = await _api.getContentStats(contentId);

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

  Future<AdminContentModel?> createContent(CreateContentModel content) async {
    try {
      final partMap = content.toFormData();

      final response = await _api.addContent(partMap);

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

  Future<bool?> updateContent(String contentId, CreateContentModel updates) async {
    try {
      final partMap = updates.toFormData();

      final response = await _api.updateContent(contentId, partMap);

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

  Future<bool?> publishContent(String contentId) async {
    try {
      final response = await _api.publishContent(contentId);

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

  Future<bool?> archiveContent(String contentId) async {
    try {
      final response = await _api.archiveContent(contentId);

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

  Future<bool?> updateGenres(String contentId, AdminContentModel updates) async {
    try {
      final response = await _api.updateGenresContent(contentId, updates);

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

  Future<bool?> addSeason(String contentId, int number, String? title) async {
    try {
      final response = await _api.addSeason(contentId, SeasonModel(number: number, title: title));

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

  Future<void> linkVideo(String contentId, {required String videoId, required String role, int position = 0}) async {
    // await _dio.post('/admin/contents/$contentId/videos', data: {
    //   'videoId': videoId,
    //   'role': role,
    //   'position': position,
    // });
  }

  Future<ContentPayoutSummary?> getPayoutsContent(String contentId) async {
    try {
      final response = await _api.getPayoutsContent(contentId);

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
