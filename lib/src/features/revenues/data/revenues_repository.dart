import 'package:dio/dio.dart';

import '../../../common/common.dart';
import 'revenue_models.dart';

class RevenuesRepository {
  final Dio _dio;

  RevenuesRepository(this._dio);

  Future<RevenueOverviewModel> getOverview() async {
    final response = await _dio.get('/admin/revenues/overview');
    return RevenueOverviewModel.fromJson(response.data['item']);
  }

  Future<List<ProducerRevenueModel>> getProducerRevenues() async {
    final response = await _dio.get('/admin/revenues/producers');
    return (response.data['items'] as List? ?? [])
        .map((j) => ProducerRevenueModel.fromJson(j))
        .toList();
  }

  Future<({List<PayoutModel> payouts, PaginationModel pagination})> getPayouts({
    int page = 1,
    int limit = 20,
    String? status,
    String? producerId,
    String? period,
  }) async {
    final queryParams = <String, dynamic>{'page': page, 'limit': limit};
    if (status != null && status.isNotEmpty) queryParams['status'] = status;
    if (producerId != null && producerId.isNotEmpty) queryParams['producer_id'] = producerId;
    if (period != null && period.isNotEmpty) queryParams['period'] = period;

    final response = await _dio.get('/admin/revenues/payouts', queryParameters: queryParams);
    final data = response.data;

    final payouts = (data['items'] as List? ?? []).map((j) => PayoutModel.fromJson(j)).toList();
    final pagination = PaginationModel.fromJson(data['pagination'] ?? {});

    return (payouts: payouts, pagination: pagination);
  }

  Future<PayoutModel> getPayoutDetail(String payoutId) async {
    final response = await _dio.get('/admin/revenues/payouts/$payoutId');
    return PayoutModel.fromJson(response.data['item']);
  }

  Future<void> approvePayout(String payoutId) async {
    await _dio.patch('/admin/revenues/payouts/$payoutId/approve');
  }

  Future<void> markPaid(String payoutId, String? paymentRef) async {
    await _dio.patch('/admin/revenues/payouts/$payoutId/pay', data: {
      if (paymentRef != null) 'paymentRef': paymentRef,
    });
  }

  Future<void> disputePayout(String payoutId) async {
    await _dio.patch('/admin/revenues/payouts/$payoutId/dispute');
  }
}
