import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../common/common.dart';
import '../content_gender.dart';

// 1. API Provider (Couche Réseau)
final contentGenderApiProvider = Provider<ContentGenderApi>((ref) {
  final dio = ref.watch(dioProvider);
  return ContentGenderApi(dio);
});

// 2. Repository Provider (Couche Données)
final contentGenderRepositoryProvider = Provider<ContentGenderRepository>((ref) {
  final api = ref.watch(contentGenderApiProvider);
  return ContentGenderRepository(api);
});

// 3. Controller Provider (Couche Logique)
final contentGenderControllerProvider = StateNotifierProvider<ContentGenderController, AsyncValue<void>>((ref) {
  final repo = ref.watch(contentGenderRepositoryProvider);
  return ContentGenderController(repo);
});
