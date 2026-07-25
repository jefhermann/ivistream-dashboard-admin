import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../common/common.dart';
import '../country.dart';

// 1. API Provider (Couche Réseau)
final countryApiProvider = Provider<CountryApi>((ref) {
  final dio = ref.watch(dioProvider);
  return CountryApi(dio);
});

// 2. Repository Provider (Couche Données)
final countryRepositoryProvider = Provider<CountryRepository>((ref) {
  final api = ref.watch(countryApiProvider);
  return CountryRepository(api);
});

// 3. Controller Provider (Couche Logique)
final countryControllerProvider = StateNotifierProvider<CountryController, AsyncValue<void>>((ref) {
  final repo = ref.watch(countryRepositoryProvider);
  return CountryController(repo);
});

