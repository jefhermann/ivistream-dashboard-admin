import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../common/common.dart';
import '../team.dart';

class CountryController extends StateNotifier<AsyncValue<void>> {

  CountryController() : super(const AsyncValue.data(null));
}

class CountryListNotifier extends AsyncNotifier<MemberListState> {
  @override
  Future<MemberListState> build() async {
    final filter = ref.watch(memberFilterProvider);
    final repo = ref.read(adminTeamRepositoryProvider);

    final result = await repo.getMembers(page: filter.page, query: filter.search);

    return MemberListState(
      members: result.items ?? [],
      pagination: result.pagination,
    );
  }
}

class MemberListState {
  final List<AdminMemberModel> members;
  final PaginationModel? pagination;

  MemberListState({this.members = const [], this.pagination});
}