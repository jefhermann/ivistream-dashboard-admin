import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../common/common.dart';
import '../person.dart';

class PersonController extends StateNotifier<AsyncValue<void>> {
  final PersonRepository _repo;

  PersonController(this._repo) : super(const AsyncValue.data(null));
}

class PersonListNotifier extends AsyncNotifier<PersonListState> {
  @override
  Future<PersonListState> build() async {
    final filter = ref.watch(personFilterProvider);
    final repo = ref.read(personRepositoryProvider);

    final result = await repo.getPersons(page: filter.page, query: filter.search);

    return PersonListState(
      person: result.items ?? [],
      pagination: result.pagination,
    );
  }

  // Action : Création
  Future<bool> createPerson({required PersonModel person}) async {
    try {
      final repo = ref.read(personRepositoryProvider);
      await repo.addPerson(person);

      ref.invalidate(personFilterProvider);
      return true;
    } catch (e) {
      return false;
    }
  }

  // Action : Mise à jour
  Future<bool> updatePerson(String id, PersonModel model) async {
    try {
      final repo = ref.read(personRepositoryProvider);
      await repo.updatePerson(id, model);

      // On rafraîchit la liste
      ref.invalidate(personFilterProvider);
      return true;
    } catch (e) {
      return false;
    }
  }
}

class PersonListState {
  final List<PersonModel> person;
  final PaginationModel? pagination;

  PersonListState({this.person = const [], this.pagination});
}
