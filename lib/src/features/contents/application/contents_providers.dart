import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../common/common.dart';
import '../../users/data/admin_user_model.dart';
import '../data/data.dart';

// 1. API Provider (Couche Réseau)
final contentApiProvider = Provider<ContentApi>((ref) {
  final dio = ref.watch(dioProvider);
  return ContentApi(dio);
});

// 2. Repository Provider (Couche Données)
final contentRepositoryProvider = Provider<ContentsRepository>((ref) {
  final api = ref.watch(contentApiProvider);
  return ContentsRepository(api);
});


// ============================================================
// Filter State
// ============================================================

class ContentsFilterState {
  final int page;
  final String? search;
  final String? status;
  final String? type;

  ContentsFilterState({this.page = 1, this.search, this.status, this.type});

  ContentsFilterState copyWith({
    int? page,
    String? search,
    String? status,
    String? type,
    bool clearSearch = false,
    bool clearStatus = false,
    bool clearType = false,
  }) {
    return ContentsFilterState(
      page: page ?? this.page,
      search: clearSearch ? null : (search ?? this.search),
      status: clearStatus ? null : (status ?? this.status),
      type: clearType ? null : (type ?? this.type),
    );
  }
}

final contentsFilterProvider = StateProvider<ContentsFilterState>((ref) {
  return ContentsFilterState();
});

// ============================================================
// Contents List
// ============================================================

class ContentsListState {
  final List<AdminContentModel> contents;
  final PaginationModel? pagination;
  final bool isLoading;
  final String? error;

  ContentsListState({this.contents = const [], this.pagination, this.isLoading = false, this.error});

  ContentsListState copyWith({
    List<AdminContentModel>? contents,
    PaginationModel? pagination,
    bool? isLoading,
    String? error,
  }) {
    return ContentsListState(
      contents: contents ?? this.contents,
      pagination: pagination ?? this.pagination,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

class ContentsListNotifier extends StateNotifier<ContentsListState> {
  final ContentsRepository _repo;

  ContentsListNotifier(this._repo) : super(ContentsListState());

  Future<void> loadContents({int page = 1, String? search, String? status, String? type}) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final result = await _repo.getContents(page: page, search: search, status: status, type: type);
      state = state.copyWith(contents: result.contents, pagination: result.pagination, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString().replaceAll('Exception: ', ''));
    }
  }

  Future<bool> publishContent(String contentId) async {
    try {
      await _repo.publishContent(contentId);
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<bool?> archiveContent(String contentId) async {
    try {
      return await _repo.archiveContent(contentId);
    } catch (_) {
      return false;
    }
  }

  Future<bool> createContent(CreateContentModel body) async {
    try {
      await _repo.createContent(body);
      return true;
    } catch (_) {
      return false;
    }
  }
}

final contentsListProvider = StateNotifierProvider<ContentsListNotifier, ContentsListState>((ref) {
  return ContentsListNotifier(ref.read(contentRepositoryProvider));
});

// ============================================================
// Content Detail
// ============================================================

final contentDetailProvider = FutureProvider.family.autoDispose<AdminContentModel?, String>((ref, contentId) async {
  final repo = ref.read(contentRepositoryProvider);
  return await repo.getContentDetail(contentId);
});

final contentPayoutsProvider = FutureProvider.family.autoDispose<ContentPayoutSummary?, String>((ref, contentId) async{
  final repo = ref.read(contentRepositoryProvider);
  return await repo.getPayoutsContent(contentId);
});

class ContentCreationController extends AsyncNotifier<void> {
  @override
  FutureOr<void> build() {
    return null; // État initial inactif
  }

  Future<bool> createContent(CreateContentModel dto) async {
    state = const AsyncValue.loading();

    try {
      final client = ref.read(contentRepositoryProvider);

      // On envoie la Map générée par le DTO à Retrofit
      await client.createContent(dto);

      state = const AsyncValue.data(null);
      return true; // Succès
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
      return false; // Échec
    }
  }

  Future<bool> updateContent(String id, CreateContentModel dto) async {
    state = const AsyncValue.loading();

    try {
      final client = ref.read(contentRepositoryProvider);

      // On envoie la Map générée par le DTO à Retrofit
      await client.updateContent(id, dto);

      state = const AsyncValue.data(null);
      return true; // Succès
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
      return false; // Échec
    }
  }
}

// 4. Le Provider global du Controller (celui que tu vas consommer dans ton UI)
final contentCreationControllerProvider =
AsyncNotifierProvider<ContentCreationController, void>(() {
  return ContentCreationController();
});
