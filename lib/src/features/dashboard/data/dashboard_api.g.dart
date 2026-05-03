// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'dashboard_api.dart';

// **************************************************************************
// RetrofitGenerator
// **************************************************************************

class _DashboardApi implements DashboardApi {
  _DashboardApi(this._dio, {this.baseUrl});

  final Dio _dio;
  String? baseUrl;

  @override
  Future<DataResponse<AdminStatsModel>> getStats() async {
    final _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{};
    final _headers = <String, dynamic>{};
    final _options = _setStreamType<DataResponse<AdminStatsModel>>(Options(
      method: 'GET',
      headers: _headers,
      extra: _extra,
    )
        .compose(
          _dio.options,
          '/admin/stats',
          queryParameters: queryParameters,
        )
        .copyWith(
            baseUrl: _combineBaseUrls(
          _dio.options.baseUrl,
          baseUrl,
        )));
    final _result = await _dio.fetch<Map<String, dynamic>>(_options);
    final _value = DataResponse<AdminStatsModel>.fromJson(
      _result.data!,
      (json) => AdminStatsModel.fromJson(json as Map<String, dynamic>),
    );
    return _value;
  }

  @override
  Future<DataResponse<RecentUserModel>> getRecentUsers({
    int page = 1,
    int limit = 5,
  }) async {
    final _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{
      r'page': page,
      r'limit': limit,
    };
    final _headers = <String, dynamic>{};
    final _options = _setStreamType<DataResponse<RecentUserModel>>(Options(
      method: 'GET',
      headers: _headers,
      extra: _extra,
    )
        .compose(
          _dio.options,
          '/admin/users',
          queryParameters: queryParameters,
        )
        .copyWith(
            baseUrl: _combineBaseUrls(
          _dio.options.baseUrl,
          baseUrl,
        )));
    final _result = await _dio.fetch<Map<String, dynamic>>(_options);
    final _value = DataResponse<RecentUserModel>.fromJson(
      _result.data!,
      (json) => RecentUserModel.fromJson(json as Map<String, dynamic>),
    );
    return _value;
  }

  @override
  Future<DataResponse<RecentContentModel>> getRecentContents({
    int page = 1,
    int limit = 5,
  }) async {
    final _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{
      r'page': page,
      r'limit': limit,
    };
    final _headers = <String, dynamic>{};
    final _options = _setStreamType<DataResponse<RecentContentModel>>(Options(
      method: 'GET',
      headers: _headers,
      extra: _extra,
    )
        .compose(
          _dio.options,
          '/admin/contents',
          queryParameters: queryParameters,
        )
        .copyWith(
            baseUrl: _combineBaseUrls(
          _dio.options.baseUrl,
          baseUrl,
        )));
    final _result = await _dio.fetch<Map<String, dynamic>>(_options);
    final _value = DataResponse<RecentContentModel>.fromJson(
      _result.data!,
      (json) => RecentContentModel.fromJson(json as Map<String, dynamic>),
    );
    return _value;
  }

  RequestOptions _setStreamType<T>(RequestOptions requestOptions) {
    if (T != dynamic &&
        !(requestOptions.responseType == ResponseType.bytes ||
            requestOptions.responseType == ResponseType.stream)) {
      if (T == String) {
        requestOptions.responseType = ResponseType.plain;
      } else {
        requestOptions.responseType = ResponseType.json;
      }
    }
    return requestOptions;
  }

  String _combineBaseUrls(String dioBaseUrl, String? baseUrl) {
    if (baseUrl == null || baseUrl.trim().isEmpty) {
      return dioBaseUrl;
    }
    final url = Uri.parse(baseUrl);
    if (url.isAbsolute) {
      return url.toString();
    }
    return Uri.parse(dioBaseUrl).resolveUri(url).toString();
  }
}
