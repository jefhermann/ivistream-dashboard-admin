import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../common/common.dart';
import '../../users/data/admin_user_model.dart';
import '../data/data.dart';

final revenuesRepositoryProvider = Provider<RevenuesRepository>((ref) {
  return RevenuesRepository(ref.read(dioProvider));
});

// Overview
final revenueOverviewProvider = FutureProvider.autoDispose<RevenueOverviewModel>((ref) async {
  return await ref.read(revenuesRepositoryProvider).getOverview();
});

// Producer revenues
final producerRevenuesProvider = FutureProvider.autoDispose<List<ProducerRevenueModel>>((ref) async {
  return await ref.read(revenuesRepositoryProvider).getProducerRevenues();
});

// Payouts filter
class PayoutsFilterState {
  final int page;
  final String? status;
  final String? producerId;

  PayoutsFilterState({this.page = 1, this.status, this.producerId});

  PayoutsFilterState copyWith({int? page, String? status, String? producerId, bool clearStatus = false, bool clearProducer = false}) {
    return PayoutsFilterState(
      page: page ?? this.page,
      status: clearStatus ? null : (status ?? this.status),
      producerId: clearProducer ? null : (producerId ?? this.producerId),
    );
  }
}

final payoutsFilterProvider = StateProvider<PayoutsFilterState>((ref) => PayoutsFilterState());

// Payouts list
class PayoutsListState {
  final List<PayoutModel> payouts;
  final PaginationModel? pagination;
  final bool isLoading;
  final String? error;

  PayoutsListState({this.payouts = const [], this.pagination, this.isLoading = false, this.error});

  PayoutsListState copyWith({List<PayoutModel>? payouts, PaginationModel? pagination, bool? isLoading, String? error}) {
    return PayoutsListState(
      payouts: payouts ?? this.payouts,
      pagination: pagination ?? this.pagination,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

class PayoutsListNotifier extends StateNotifier<PayoutsListState> {
  final RevenuesRepository _repo;

  PayoutsListNotifier(this._repo) : super(PayoutsListState());

  Future<void> loadPayouts({int page = 1, String? status, String? producerId}) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final result = await _repo.getPayouts(page: page, status: status, producerId: producerId);
      state = state.copyWith(payouts: result.payouts, pagination: result.pagination, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString().replaceAll('Exception: ', ''));
    }
  }

  Future<bool> approvePayout(String id) async {
    try { await _repo.approvePayout(id); return true; } catch (_) { return false; }
  }

  Future<bool> markPaid(String id, String? ref) async {
    try { await _repo.markPaid(id, ref); return true; } catch (_) { return false; }
  }

  Future<bool> disputePayout(String id) async {
    try { await _repo.disputePayout(id); return true; } catch (_) { return false; }
  }
}

final payoutsListProvider = StateNotifierProvider<PayoutsListNotifier, PayoutsListState>((ref) {
  return PayoutsListNotifier(ref.read(revenuesRepositoryProvider));
});

// Payout detail
final payoutDetailProvider = FutureProvider.family.autoDispose<PayoutModel, String>((ref, id) async {
  return await ref.read(revenuesRepositoryProvider).getPayoutDetail(id);
});
