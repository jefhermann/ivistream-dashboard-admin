import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../common/common.dart';
import '../../users/data/admin_user_model.dart';
import '../data/data.dart';

// ============================================================
// Repository
// ============================================================

final producersRepositoryProvider = Provider<ProducersRepository>((ref) {
  return ProducersRepository(ref.read(dioProvider));
});

// ============================================================
// Filter State
// ============================================================

class ProducersFilterState {
  final int page;
  final String? search;

  ProducersFilterState({this.page = 1, this.search});

  ProducersFilterState copyWith({int? page, String? search, bool clearSearch = false}) {
    return ProducersFilterState(
      page: page ?? this.page,
      search: clearSearch ? null : (search ?? this.search),
    );
  }
}

final producersFilterProvider = StateProvider<ProducersFilterState>((ref) {
  return ProducersFilterState();
});

// ============================================================
// Producers List
// ============================================================

class ProducersListState {
  final List<AdminProducerModel> producers;
  final PaginationModel? pagination;
  final bool isLoading;
  final String? error;

  ProducersListState({
    this.producers = const [],
    this.pagination,
    this.isLoading = false,
    this.error,
  });

  ProducersListState copyWith({
    List<AdminProducerModel>? producers,
    PaginationModel? pagination,
    bool? isLoading,
    String? error,
  }) {
    return ProducersListState(
      producers: producers ?? this.producers,
      pagination: pagination ?? this.pagination,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

class ProducersListNotifier extends StateNotifier<ProducersListState> {
  final ProducersRepository _repo;

  ProducersListNotifier(this._repo) : super(ProducersListState());

  Future<void> loadProducers({int page = 1, String? search}) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final result = await _repo.getProducers(page: page, search: search);
      state = state.copyWith(
        producers: result.producers,
        pagination: result.pagination,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString().replaceAll('Exception: ', ''),
      );
    }
  }

  Future<bool> createProducer({required String name, String? description, String? countryCode}) async {
    try {
      await _repo.createProducer(name: name, description: description, countryCode: countryCode);
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> updateProducer(String producerId, {String? name, String? description, bool? isVerified}) async {
    try {
      await _repo.updateProducer(producerId, name: name, description: description, isVerified: isVerified);
      return true;
    } catch (e) {
      return false;
    }
  }
}

final producersListProvider = StateNotifierProvider<ProducersListNotifier, ProducersListState>((ref) {
  return ProducersListNotifier(ref.read(producersRepositoryProvider));
});

// ============================================================
// Producer Detail
// ============================================================

final producerDetailProvider = FutureProvider.family.autoDispose<AdminProducerModel, String>((ref, producerId) async {
  final repo = ref.read(producersRepositoryProvider);
  return await repo.getProducerDetail(producerId);
});
