import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../common/common.dart';
import '../country.dart';

class CountryController extends StateNotifier<AsyncValue<void>> {
  final CountryRepository _repo;

  CountryController(this._repo) : super(const AsyncValue.data(null));
}

class CountryListNotifier extends AsyncNotifier<CountryListState> {
  @override
  Future<CountryListState> build() async {
    final filter = ref.watch(countryFilterProvider);
    final repo = ref.read(countryRepositoryProvider);

    final result = await repo.getCountries(page: filter.page, query: filter.search);

    return CountryListState(
      country: result.items ?? [],
      pagination: result.pagination,
    );
  }

  // Action : Création
  Future<bool> createCountry({required CountryModel country}) async {
    try {
      final repo = ref.read(countryRepositoryProvider);
      await repo.addCountry(country);

      ref.invalidate(countryFilterProvider);
      return true;
    } catch (e) {
      return false;
    }
  }

  // Action : Mise à jour
  Future<bool> updateCountry(String id, {String? name, String? zone, bool? isActive, String? code}) async {
    try {
      final repo = ref.read(countryRepositoryProvider);
      await repo.updateCountry(id, CountryModel(name: name, isActive: isActive, zone: zone, code: code));

      // On rafraîchit la liste
      ref.invalidate(countryFilterProvider);
      return true;
    } catch (e) {
      return false;
    }
  }
}

class CountryListState {
  final List<CountryModel> country;
  final PaginationModel? pagination;

  CountryListState({this.country = const [], this.pagination});
}
