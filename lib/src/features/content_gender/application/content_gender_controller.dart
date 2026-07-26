import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../common/common.dart';
import '../content_gender.dart';

class ContentGenderController extends StateNotifier<AsyncValue<void>> {
  final ContentGenderRepository _repo;

  ContentGenderController(this._repo) : super(const AsyncValue.data(null));
}

class ContentGenderListNotifier extends AsyncNotifier<ContentGenderListState> {
  @override
  Future<ContentGenderListState> build() async {
    final filter = ref.watch(contentGenderFilterProvider);
    final repo = ref.read(contentGenderRepositoryProvider);

    final result = await repo.getGenres(page: filter.page, query: filter.search);

    return ContentGenderListState(
      genders: result.items ?? [],
      pagination: result.pagination,
    );
  }

  // Action : Création
  Future<bool> createContentGender({required String name}) async {
    try {
      final repo = ref.read(contentGenderRepositoryProvider);
      await repo.addGenres(GenreModel(name: name));

      ref.invalidate(contentGenderFilterProvider);
      return true;
    } catch (e) {
      return false;
    }
  }

  // Action : Mise à jour
  Future<bool> updateContentGender(String id, {String? name, bool? isActive}) async {
    try {
      final repo = ref.read(contentGenderRepositoryProvider);
      await repo.updateGenre(id,GenreModel(name: name, isActive: isActive));

      // On rafraîchit la liste
      ref.invalidate(contentGenderFilterProvider);
      return true;
    } catch (e) {
      return false;
    }
  }
}

class ContentGenderListState {
  final List<GenreModel> genders;
  final PaginationModel? pagination;

  ContentGenderListState({this.genders = const [], this.pagination});
}
