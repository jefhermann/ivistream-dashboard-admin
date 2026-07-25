import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../person.dart';

class PersonController extends StateNotifier<AsyncValue<void>> {
final PersonRepository _repo;

PersonController(this._repo) : super(const AsyncValue.data(null));

}