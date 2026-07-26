import 'package:flutter_riverpod/flutter_riverpod.dart';

class PersonFilterState {
  final int page;
  final String? search;

  PersonFilterState({this.page = 1, this.search});

  PersonFilterState copyWith({int? page, String? search, bool clearSearch = false}) {
    return PersonFilterState(
      page: page ?? this.page,
      search: clearSearch ? null : (search ?? this.search),
    );
  }
}

// On garde le StateProvider pour stocker les inputs de recherche de l'UI
final personFilterProvider = StateProvider<PersonFilterState>((ref) {
  return PersonFilterState();
});