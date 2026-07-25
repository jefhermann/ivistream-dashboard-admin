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

final queryPersonProvider = StateProvider.autoDispose<String?>((ref) => null);

final listPersonProvider = FutureProvider.autoDispose<List<PersonModel>>((ref) async {
  final repo = ref.read(personRepositoryProvider);
  final query = ref.watch(queryPersonProvider);
  return await repo.getPersons(query: query);
});

final addPersonProvider = FutureProvider.family.autoDispose<bool, PersonModel>((ref, body) async {
  final repo = ref.read(personRepositoryProvider);
  return await repo.addPerson(body);
});

class AddPersonController extends AutoDisposeAsyncNotifier<void> {
  @override
  FutureOr<void> build() {
    // État initial (aucune action en cours)
  }

  /// Exécute la mutation, gère l'état et retourne un booléen
  Future<bool> execute(PersonModel body) async {
    // Bloque les requêtes multiples si on est déjà en train de charger
    if (state.isLoading) return false;

    state = const AsyncValue.loading();

    try {
      final repo = ref.read(personRepositoryProvider);

      // Assure-toi que ta méthode de repo lance une exception si l'API échoue
      await repo.addPerson(body);

      state = const AsyncValue.data(null);
      return true; // Succès de l'opération
    } catch (error, stackTrace) {
      // Gestion d'erreur stricte : on capture et on met à jour l'état
      state = AsyncValue.error(error, stackTrace);
      return false; // Échec de l'opération
    }
  }
}

// 2. Déclaration du Provider
final addPersonControllerProvider = AsyncNotifierProvider.autoDispose<AddPersonController, void>(
  AddPersonController.new,
);
