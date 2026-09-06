import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../common/common.dart';
import '../auth.dart';

// ============================================================
// Auth State
// ============================================================

class AuthState {
  final bool isInitializing;
  final bool isLoading;
  final bool isAuthenticated;
  final UserModel? user;
  final String? error;

  AuthState({
    this.isInitializing = true,
    this.isLoading = false,
    this.isAuthenticated = false,
    this.user,
    this.error,
  });

  AuthState copyWith({
    bool? isInitializing,
    bool? isLoading,
    bool? isAuthenticated,
    UserModel? user,
    String? error,
  }) {
    return AuthState(
      isInitializing: isInitializing ?? this.isInitializing,
      isLoading: isLoading ?? this.isLoading,
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      user: user ?? this.user,
      error: error,
    );
  }
}

// ============================================================
// Auth Controller
// ============================================================

class AuthController extends StateNotifier<AuthState> {
  final AuthRepository _repository;

  AuthController(this._repository) : super(AuthState());

  Future<void> init() async {
    try {

      final response = await _repository.getUserInfos();

      if (response.hasError == true || response.item == null) {
        throw Exception(response.message ?? "Erreur lors de la récupération du profil");
      }

      final data = response.item!;

      state = state.copyWith(
        isInitializing: false,
        isAuthenticated: true,
        user: data.user,
      );
    } catch (e) {
      state = state.copyWith(
        isInitializing: false,
        isAuthenticated: false,
        error: e.toString(),
      );
    }
  }

  Future<bool> login(String email, String password) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final response = await _repository.login(email, password);

      if (response.hasError! || response.item == null) {
        state = state.copyWith(isLoading: false, error: response.message);
        return false;
      }

      final data = response.item!;

      state = state.copyWith(
        isLoading: false,
        isAuthenticated: true,
        user: data.user,
      );
      return true;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString().replaceAll('Exception: ', ''),
      );
      return false;
    }
  }

  Future<void> logout() async {
    var logout = await _repository.logout();
    if (!logout) return;

    await SharedPreferencesService.clear();

    state = AuthState(
      isInitializing: false,
      isAuthenticated: false,
      user: null,
    );

    return;
  }
}

// ============================================================
// Providers
// ============================================================

final authApiProvider = Provider<AuthApi>((ref) {
  return AuthApi(ref.read(dioProvider));
});

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository(ref.read(authApiProvider));
});

final authControllerProvider = StateNotifierProvider<AuthController, AuthState>((ref) {
  return AuthController(ref.read(authRepositoryProvider));
});

// ChangeNotifier pour auto_route reevaluateListenable
class _AuthChangeNotifier extends ChangeNotifier {
  bool _isAuthenticated = false;

  void update(bool isAuthenticated) {
    if (_isAuthenticated != isAuthenticated) {
      _isAuthenticated = isAuthenticated;
      notifyListeners();
    }
  }
}

final authChangeNotifierProvider = Provider<_AuthChangeNotifier>((ref) {
  final notifier = _AuthChangeNotifier();
  ref.listen(authControllerProvider, (prev, next) {
    notifier.update(next.isAuthenticated);
  });
  return notifier;
});
