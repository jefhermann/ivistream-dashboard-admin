import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../common.dart';

final dioProvider = Provider<Dio>((ref) {
  final dio = Dio(
    BaseOptions(
      baseUrl: AppConfig.apiBaseUrl,
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'X-Client-Type': 'WEB_ADMIN',
      },
      extra: {'withCredentials': true},
      connectTimeout: const Duration(seconds: 20),
      receiveTimeout: const Duration(seconds: 20),
    ),
  );

  Future<bool>? refreshingFuture;

  dio.interceptors.add(
    QueuedInterceptorsWrapper(
      onError: (DioException e, handler) async {
        final path = e.requestOptions.path;
        final isAuthRoute = path.contains('/auth/refresh') || path.contains('/admin/login');

        if (e.response?.statusCode == 401 && !isAuthRoute) {
          refreshingFuture ??= _refreshSession(dio);
          final refreshed = await refreshingFuture!;
          refreshingFuture = null;

          if (refreshed) {
            try {
              final response = await dio.fetch(e.requestOptions);
              return handler.resolve(response);
            } on DioException catch (retryError) {
              return handler.next(retryError);
            }
          }
        }
        return handler.next(e);
      },
    ),
  );

  return dio;
});

Future<bool> _refreshSession(Dio dio) async {
  try {
    final response = await dio.post('/auth/refresh');
    return response.statusCode == 200 || response.statusCode == 201;
  } on DioException catch (e) {
    debugPrint("--- SESSION REFRESH FAILED: $e ---");
    return false;
  }
}