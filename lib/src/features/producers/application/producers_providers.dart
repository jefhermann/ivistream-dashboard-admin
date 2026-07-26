import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../common/common.dart';
import '../data/data.dart';

// ============================================================
// Repository
// ============================================================
final producersRepositoryProvider = Provider<ProducersRepository>((ref) {
  return ProducersRepository(ref.read(dioProvider));
});

// ============================================================
// Filter State (Immuable & Propre)
// ============================================================
class ProducersFilterState {
  final int page;
  final String? search;

  ProducersFilterState({this.page = 1, this.search});

  ProducersFilterState copyWith({int? page, String? search, bool clearSearch = false}) {
    return ProducersFilterState(
      page: page ?? this.page,
      search: clearSearch ? null : (search ?? this.search),
    );
  }
}

// On garde le StateProvider pour stocker les inputs de recherche de l'UI
final producersFilterProvider = StateProvider<ProducersFilterState>((ref) {
  return ProducersFilterState();
});

// ============================================================
// Producers List & Actions (Le Cerveau Réactif 👑)
// ============================================================
class ProducersListState {
  final List<AdminProducerModel> producers;
  final PaginationModel? pagination;

  ProducersListState({this.producers = const [], this.pagination});
}

class ProducersListNotifier extends AutoDisposeAsyncNotifier<ProducersListState> {
  @override
  Future<ProducersListState> build() async {
    // 👑 MAGIE RÉACTIVE : On écoute activement le filtre.
    // Dès que producersFilterProvider change (recherche ou page),
    // build() se relance AUTOMATIQUEMENT et met l'état global en AsyncLoading !
    final filter = ref.watch(producersFilterProvider);
    final repo = ref.read(producersRepositoryProvider);

    final result = await repo.getProducers(page: filter.page, search: filter.search);

    return ProducersListState(
      producers: result.producers,
      pagination: result.pagination,
    );
  }

  // Action : Création
  Future<bool> createProducer({required String name, String? description, String? countryCode, String? contact, String? email}) async {
    try {
      final repo = ref.read(producersRepositoryProvider);
      await repo.createProducer(name: name, description: description, countryCode: countryCode, contact: contact, email: email);

      // 👑 ULTRA IMPORTANT : On invalide le filtre pour forcer la liste à se recharger
      // et à afficher instantanément le nouveau producteur dans ton Dropdown.
      ref.invalidate(producersFilterProvider);
      return true;
    } catch (e) {
      return false;
    }
  }

  // Action : Mise à jour
  Future<bool> updateProducer(String producerId, {String? name, String? description, bool? isVerified, String? contact, String? email}) async {
    try {
      final repo = ref.read(producersRepositoryProvider);
      await repo.updateProducer(producerId, name: name, description: description, isVerified: isVerified, contact: contact, email: email);

      // On rafraîchit la liste
      ref.invalidate(producersFilterProvider);
      // On invalide aussi le détail spécifique s'il est ouvert quelque part
      ref.invalidate(producerDetailProvider(producerId));
      return true;
    } catch (e) {
      return false;
    }
  }
}

final producersListProvider = AsyncNotifierProvider.autoDispose<ProducersListNotifier, ProducersListState>(() {
  return ProducersListNotifier();
});

// ============================================================
// Producer Detail
// ============================================================
final producerDetailProvider = FutureProvider.family.autoDispose<AdminProducerModel, String>((ref, producerId) async {
  final repo = ref.read(producersRepositoryProvider);
  return await repo.getProducerDetail(producerId);
});