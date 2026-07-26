import 'package:dio/dio.dart';

import '../../../common/common.dart';
import 'admin_producer_model.dart';

class ProducersRepository {
  final Dio _dio;

  ProducersRepository(this._dio);

  Future<({List<AdminProducerModel> producers, PaginationModel pagination})> getProducers({
    int page = 1,
    int limit = 20,
    String? search,
  }) async {
    final queryParams = <String, dynamic>{
      'page': page,
      'limit': limit,
    };
    if (search != null && search.isNotEmpty) queryParams['search'] = search;

    final response = await _dio.get('/admin/producers', queryParameters: queryParams);
    final data = response.data;

    final producers = (data['items'] as List? ?? [])
        .map((json) => AdminProducerModel.fromJson(json))
        .toList();

    final pagination = PaginationModel.fromJson(data['pagination'] ?? {});

    return (producers: producers, pagination: pagination);
  }

  Future<AdminProducerModel> getProducerDetail(String producerId) async {
    final response = await _dio.get('/admin/producers/$producerId');
    return AdminProducerModel.fromJson(response.data['item']);
  }

  Future<AdminProducerModel> createProducer({
    required String name,
    String? description,
    String? countryCode,
    String? logoUrl,
    String? contact,
    String? email,
  }) async {
    final response = await _dio.post('/admin/producers', data: {
      'name': name,
      if (description != null) 'description': description,
      if (countryCode != null) 'countryCode': countryCode,
      if (logoUrl != null) 'logoUrl': logoUrl,
      if (contact != null) 'contact': contact,
      if (email != null) 'email': email,
    });
    return AdminProducerModel.fromJson(response.data['item']);
  }

  Future<AdminProducerModel> updateProducer(String producerId, {
    String? name,
    String? description,
    String? countryCode,
    String? logoUrl,
    bool? isVerified,
    String? contact,
    String? email,
  }) async {
    final body = <String, dynamic>{};
    if (name != null) body['name'] = name;
    if (description != null) body['description'] = description;
    if (countryCode != null) body['countryCode'] = countryCode;
    if (logoUrl != null) body['logoUrl'] = logoUrl;
    if (isVerified != null) body['isVerified'] = isVerified;
    if (contact != null) body['contact'] = contact;
    if (email != null) body['email'] = email;

    final response = await _dio.put('/admin/producers/$producerId', data: body);
    return AdminProducerModel.fromJson(response.data['item']);
  }

  Future<void> addMember(String producerId, String userId, String role) async {
    await _dio.post('/admin/producers/$producerId/members', data: {
      'userId': userId,
      'role': role,
    });
  }

  Future<void> removeMember(String producerId, String memberId) async {
    await _dio.delete('/admin/producers/$producerId/members/$memberId');
  }
}
