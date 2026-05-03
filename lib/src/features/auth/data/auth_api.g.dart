// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'auth_api.dart';

// **************************************************************************
// RetrofitGenerator
// **************************************************************************

class _AuthApi implements AuthApi {
  _AuthApi(this._dio, {this.baseUrl});

  final Dio _dio;
  String? baseUrl;

  @override
  Future<DataResponse<TokenModel>> login(UserModel user) async {
    final _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{};
    final _headers = <String, dynamic>{};
    final _data = user.toJson();
    final _options = _setStreamType<DataResponse<TokenModel>>(Options(
      method: 'POST',
      headers: _headers,
      extra: _extra,
    )
        .compose(
          _dio.options,
          '/admin/login',
          queryParameters: queryParameters,
          data: _data,
        )
        .copyWith(
            baseUrl: _combineBaseUrls(
          _dio.options.baseUrl,
          baseUrl,
        )));
    final _result = await _dio.fetch<Map<String, dynamic>>(_options);
    final _value = DataResponse<TokenModel>.fromJson(
      _result.data!,
      (json) => TokenModel.fromJson(json as Map<String, dynamic>),
    );
    return _value;
  }

  @override
  Future<DataResponse<AdminInfoModel>> profile() async {
    final _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{};
    final _headers = <String, dynamic>{};
    final _options = _setStreamType<DataResponse<AdminInfoModel>>(Options(
      method: 'GET',
      headers: _headers,
      extra: _extra,
    )
        .compose(
          _dio.options,
          '/admin/me',
          queryParameters: queryParameters,
        )
        .copyWith(
            baseUrl: _combineBaseUrls(
          _dio.options.baseUrl,
          baseUrl,
        )));
    final _result = await _dio.fetch<Map<String, dynamic>>(_options);
    final _value = DataResponse<AdminInfoModel>.fromJson(
      _result.data!,
      (json) => AdminInfoModel.fromJson(json as Map<String, dynamic>),
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
