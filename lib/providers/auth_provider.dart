

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:currensee/services/auth_service.dart';
import 'package:currensee/models/user.dart';

// ─── Service Provider ─────────────────────────────────────────────────────
final authServiceProvider = Provider<AuthService>((ref) {
  return AuthService();
});

// ─── Firebase Auth State Stream ───────────────────────────────────────────
final authStateProvider = StreamProvider<User?>((ref) {
  final authService = ref.watch(authServiceProvider);
  return authService.authStateChanges;
});

// ─── Current AppUser Provider ─────────────────────────────────────────────
final currentUserProvider = StateProvider<AppUser?>((ref) => null);

// ─── Auth State Notifier ──────────────────────────────────────────────────
class AuthNotifier extends StateNotifier<AsyncValue<void>> {
  final AuthService _authService;
  final Ref _ref;

  AuthNotifier(this._authService, this._ref) : super(const AsyncValue.data(null));

  Future<bool> register({
    required String email,
    required String password,
    required String fullName,
  }) async {
    state = const AsyncValue.loading();
    try {
      final user = await _authService.registerWithEmail(
        email: email,
        password: password,
        fullName: fullName,
      );
      _ref.read(currentUserProvider.notifier).state = user;
      state = const AsyncValue.data(null);
      return true;
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
      return false;
    }
  }

  Future<bool> login({
    required String email,
    required String password,
  }) async {
    state = const AsyncValue.loading();
    try {
      final user = await _authService.loginWithEmail(
        email: email,
        password: password,
      );
      _ref.read(currentUserProvider.notifier).state = user;
      state = const AsyncValue.data(null);
      return true;
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
      return false;
    }
  }

  Future<bool> signInWithGoogle() async {
    state = const AsyncValue.loading();
    try {
      final user = await _authService.signInWithGoogle();
      _ref.read(currentUserProvider.notifier).state = user;
      state = const AsyncValue.data(null);
      return true;
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
      return false;
    }
  }

  Future<void> signOut() async {
    await _authService.signOut();
    _ref.read(currentUserProvider.notifier).state = null;
    state = const AsyncValue.data(null);
  }

  Future<bool> sendPasswordReset(String email) async {
    state = const AsyncValue.loading();
    try {
      await _authService.sendPasswordResetEmail(email);
      state = const AsyncValue.data(null);
      return true;
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
      return false;
    }
  }

  String? getErrorMessage() {
    return state.maybeWhen(
      error: (e, _) => e.toString(),
      orElse: () => null,
    );
  }
}

final authNotifierProvider =
StateNotifierProvider<AuthNotifier, AsyncValue<void>>((ref) {
  return AuthNotifier(ref.watch(authServiceProvider), ref);
});