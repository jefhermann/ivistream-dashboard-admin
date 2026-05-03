import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../common/common.dart';
import '../data/data.dart';

// ============================================================
// Repository
// ============================================================

final usersRepositoryProvider = Provider<UsersRepository>((ref) {
  return UsersRepository(ref.read(dioProvider));
});

// ============================================================
// Filter State
// ============================================================

class UsersFilterState {
  final int page;
  final String? search;
  final String? status; // active, inactive
  final String? trialStatus; // available, active, expired, converted

  UsersFilterState({
    this.page = 1,
    this.search,
    this.status,
    this.trialStatus,
  });

  UsersFilterState copyWith({
    int? page,
    String? search,
    String? status,
    String? trialStatus,
    bool clearSearch = false,
    bool clearStatus = false,
    bool clearTrialStatus = false,
  }) {
    return UsersFilterState(
      page: page ?? this.page,
      search: clearSearch ? null : (search ?? this.search),
      status: clearStatus ? null : (status ?? this.status),
      trialStatus: clearTrialStatus ? null : (trialStatus ?? this.trialStatus),
    );
  }
}

final usersFilterProvider = StateProvider<UsersFilterState>((ref) {
  return UsersFilterState();
});

// ============================================================
// Users List
// ============================================================

class UsersListState {
  final List<AdminUserModel> users;
  final PaginationModel? pagination;
  final bool isLoading;
  final String? error;

  UsersListState({
    this.users = const [],
    this.pagination,
    this.isLoading = false,
    this.error,
  });

  UsersListState copyWith({
    List<AdminUserModel>? users,
    PaginationModel? pagination,
    bool? isLoading,
    String? error,
  }) {
    return UsersListState(
      users: users ?? this.users,
      pagination: pagination ?? this.pagination,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

class UsersListNotifier extends StateNotifier<UsersListState> {
  final UsersRepository _repo;

  UsersListNotifier(this._repo) : super(UsersListState());

  Future<void> loadUsers({
    int page = 1,
    String? search,
    String? status,
    String? trialStatus,
  }) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final result = await _repo.getUsers(
        page: page,
        search: search,
        status: status,
        trialStatus: trialStatus,
      );

      state = state.copyWith(
        users: result.users,
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

  Future<bool> toggleUserStatus(String userId, bool isActive) async {
    try {
      await _repo.toggleUserStatus(userId, isActive);
      // Met à jour localement
      state = state.copyWith(
        users: state.users.map((u) {
          if (u.id == userId) {
            return AdminUserModel(
              id: u.id,
              email: u.email,
              fullName: u.fullName,
              phone: u.phone,
              countryCode: u.countryCode,
              isActive: isActive,
              emailVerified: u.emailVerified,
              trialStatus: u.trialStatus,
              trialStartedAt: u.trialStartedAt,
              trialEndsAt: u.trialEndsAt,
              trialDurationDays: u.trialDurationDays,
              createdAt: u.createdAt,
              lastSignInAt: u.lastSignInAt,
            );
          }
          return u;
        }).toList(),
      );
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> extendTrial(String userId, int days) async {
    try {
      await _repo.extendTrial(userId, days);
      return true;
    } catch (e) {
      return false;
    }
  }
}

final usersListProvider = StateNotifierProvider<UsersListNotifier, UsersListState>((ref) {
  return UsersListNotifier(ref.read(usersRepositoryProvider));
});

// ============================================================
// User Detail
// ============================================================

final userDetailProvider = FutureProvider.family.autoDispose<AdminUserModel, String>((ref, userId) async {
  final repo = ref.read(usersRepositoryProvider);
  return await repo.getUserDetail(userId);
});
