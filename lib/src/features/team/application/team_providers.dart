import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../common/common.dart';
import '../data/data.dart';

final teamRepositoryProvider = Provider<TeamRepository>((ref) {
  return TeamRepository(ref.read(dioProvider));
});

class TeamListState {
  final List<AdminTeamMemberModel> members;
  final bool isLoading;
  final String? error;

  TeamListState({this.members = const [], this.isLoading = false, this.error});

  TeamListState copyWith({List<AdminTeamMemberModel>? members, bool? isLoading, String? error}) {
    return TeamListState(
      members: members ?? this.members,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

class TeamListNotifier extends StateNotifier<TeamListState> {
  final TeamRepository _repo;

  TeamListNotifier(this._repo) : super(TeamListState());

  Future<void> loadTeam() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final members = await _repo.getTeam();
      state = state.copyWith(members: members, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString().replaceAll('Exception: ', ''));
    }
  }

  Future<bool> addMember(String userId, String role) async {
    try {
      await _repo.addMember(userId, role);
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<bool> updateMember(String adminId, {String? role, bool? isActive}) async {
    try {
      await _repo.updateMember(adminId, role: role, isActive: isActive);
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<bool> removeMember(String adminId) async {
    try {
      await _repo.removeMember(adminId);
      return true;
    } catch (_) {
      return false;
    }
  }
}

final teamListProvider = StateNotifierProvider<TeamListNotifier, TeamListState>((ref) {
  return TeamListNotifier(ref.read(teamRepositoryProvider));
});
