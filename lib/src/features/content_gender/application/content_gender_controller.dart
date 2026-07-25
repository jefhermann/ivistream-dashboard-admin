import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../content_gender.dart';

class ContentGenderController extends StateNotifier<AsyncValue<void>> {
final ContentGenderRepository _repo;

ContentGenderController(this._repo) : super(const AsyncValue.data(null));

}