import 'package:flutter_riverpod/flutter_riverpod.dart';

class ContentGenderFilterState {
  final int page;
  final String? search;

  ContentGenderFilterState({this.page = 1, this.search});

  ContentGenderFilterState copyWith({int? page, String? search, bool clearSearch = false}) {
    return ContentGenderFilterState(
      page: page ?? this.page,
      search: clearSearch ? null : (search ?? this.search),
    );
  }
}

// On garde le StateProvider pour stocker les inputs de recherche de l'UI
final contentGenderFilterProvider = StateProvider<ContentGenderFilterState>((ref) {
  return ContentGenderFilterState();
});