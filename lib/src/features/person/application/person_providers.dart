import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../common/common.dart';
import '../person.dart';

// 1. API Provider (Couche Réseau)
final personApiProvider = Provider<PersonApi>((ref) {
  final dio = ref.watch(dioProvider);
  return PersonApi(dio);
});

// 2. Repository Provider (Couche Données)
final personRepositoryProvider = Provider<PersonRepository>((ref) {
  final api = ref.watch(personApiProvider);
  return PersonRepository(api);
});

// 3. Controller Provider (Couche Logique)
final personControllerProvider = StateNotifierProvider<PersonController, AsyncValue<void>>((ref) {
  final repo = ref.watch(personRepositoryProvider);
  return PersonController(repo);
});

final personListProvider = AsyncNotifierProvider<PersonListNotifier, PersonListState>(() {
  return PersonListNotifier();
});
