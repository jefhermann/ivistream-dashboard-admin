import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../common/common.dart';
import '../data/data.dart';

final dashboardApiProvider = Provider<DashboardApi>((ref) {
  return DashboardApi(ref.read(dioProvider));
});

final dashboardRepositoryProvider = Provider<DashboardRepository>((ref) {
  return DashboardRepository(ref.read(dashboardApiProvider));
});

final adminStatsProvider = FutureProvider.autoDispose<AdminStatsModel>((ref) async {
  final repo = ref.read(dashboardRepositoryProvider);
  final response = await repo.getStats();

  if (response.hasError == true || response.item == null) {
    return AdminStatsModel.empty();
  }

  return response.item!;
});

final recentUsersProvider = FutureProvider.autoDispose<List<RecentUserModel>>((ref) async {
  final repo = ref.read(dashboardRepositoryProvider);
  final response = await repo.getRecentUsers();

  return response.items ?? [];
});

final recentContentsProvider = FutureProvider.autoDispose<List<RecentContentModel>>((ref) async {
  final repo = ref.read(dashboardRepositoryProvider);
  final response = await repo.getRecentContents();

  return response.items ?? [];
});
