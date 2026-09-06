import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../common.dart';

Future<String?> _refreshToken() async {
  final refreshToken = await SharedPreferencesService.getRefreshToken();
  if (refreshToken == null) return null;

  try {
    final refreshDio = Dio(BaseOptions(baseUrl: AppConfig.apiBaseUrl));

    debugPrint("--- REFRESHING TOKEN ---");

    final response = await refreshDio.post('/auth/refresh', data: {
      'refresh_token': refreshToken,
    });

    debugPrint("response status code: ${response.statusCode}");

    if (response.statusCode == 200 || response.statusCode == 201) {
      final item = response.data['item'];
      final newAccessToken = item['access_token'];
      final newRefreshToken = item['refresh_token'];

      await SharedPreferencesService.saveToken(newAccessToken);
      await SharedPreferencesService.saveRefreshToken(newRefreshToken);

      debugPrint("--- TOKEN REFRESHED SUCCESS ---");
      return newAccessToken;
    }
  } on DioException catch (e) {
    debugPrint("--- TOKEN REFRESH FAILED: $e ---");
    debugPrint("data: ${e.response?.data}");
    return null;
  }
  return null;
}

final dioProvider = Provider<Dio>((ref) {
  final options = BaseOptions(
    baseUrl: AppConfig.apiBaseUrl,
    headers: {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'X-Client-Type': 'WEB_ADMIN',
    },
    extra: {'withCredentials': true},
    connectTimeout: const Duration(seconds: 20),
    receiveTimeout: const Duration(seconds: 20),
  );

  final dio = Dio(options);

  Future<String?>? refreshTokenFuture;

  dio.interceptors.add(
    QueuedInterceptorsWrapper(
      onRequest: (options, handler) async {
        if (refreshTokenFuture != null) {
          await refreshTokenFuture;
        }

        return handler.next(options);
      },
      onError: (DioException e, handler) async {
        if (e.response?.statusCode == 401 && !e.requestOptions.path.contains('/auth/') && !e.requestOptions.path.contains('/admin/login')) {
          final String? newToken;

          if (refreshTokenFuture != null) {
            newToken = await refreshTokenFuture;
          } else {
            refreshTokenFuture = _refreshToken();
            newToken = await refreshTokenFuture;
            refreshTokenFuture = null;
          }

          if (newToken != null) {
            final opts = e.requestOptions;
            opts.headers['Authorization'] = 'Bearer $newToken';

            try {
              final response = await dio.fetch(opts);
              return handler.resolve(response);
            } on DioException catch (retryError) {
              return handler.next(retryError);
            }
          } else {
            return handler.next(e);
          }
        }

        return handler.next(e);
      },
    ),
  );

  return dio;
});
