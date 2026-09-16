import 'package:flutter_riverpod/flutter_riverpod.dart';

class MemberFilterState {
  final int page;
  final String? search;

  MemberFilterState({this.page = 1, this.search});

  MemberFilterState copyWith({int? page, String? search, bool clearSearch = false}) {
    return MemberFilterState(
      page: page ?? this.page,
      search: clearSearch ? null : (search ?? this.search),
    );
  }
}

// On garde le StateProvider pour stocker les inputs de recherche de l'UI
final memberFilterProvider = StateProvider<MemberFilterState>((ref) {
  return MemberFilterState();
});