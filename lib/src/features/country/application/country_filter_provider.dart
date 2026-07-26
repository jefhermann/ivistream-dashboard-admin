import 'package:flutter_riverpod/flutter_riverpod.dart';

class CountryFilterState {
  final int page;
  final String? search;

  CountryFilterState({this.page = 1, this.search});

  CountryFilterState copyWith({int? page, String? search, bool clearSearch = false}) {
    return CountryFilterState(
      page: page ?? this.page,
      search: clearSearch ? null : (search ?? this.search),
    );
  }
}

// On garde le StateProvider pour stocker les inputs de recherche de l'UI
final countryFilterProvider = StateProvider<CountryFilterState>((ref) {
  return CountryFilterState();
});