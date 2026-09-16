import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../common/common.dart';
import '../team.dart';

// TODO: si ton projet fournit déjà un dioProvider (via common.dart), remplace
// directement AdminTeamApi(ref.watch(dioProvider)) ci-dessous — j'assume que
// c'est là qu'il vit, comme baseUrl/withCredentials pour le reste de l'app.
final adminTeamApiProvider = Provider<AdminTeamApi>((ref) {
  return AdminTeamApi(ref.watch(dioProvider));
});

final adminTeamRepositoryProvider = Provider<AdminTeamRepository>((ref) {
  return AdminTeamRepository(ref.watch(adminTeamApiProvider));
});

final adminTeamInvitationsProvider = FutureProvider.autoDispose<List<AdminInvitationModel>>((ref) {
  return ref.watch(adminTeamRepositoryProvider).getInvitations();
});


final memberListProvider = AsyncNotifierProvider<CountryListNotifier, MemberListState>(() {
  return CountryListNotifier();
});