import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../country.dart';

class CountryController extends StateNotifier<AsyncValue<void>> {
final CountryRepository _repo;

CountryController(this._repo) : super(const AsyncValue.data(null));

}