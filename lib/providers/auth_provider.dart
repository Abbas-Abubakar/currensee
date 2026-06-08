

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
final currentUserProvider = Provider<AppUser?>((ref) {
  final authState = ref.watch(authStateProvider);
  return authState.whenData((user) {
    if (user == null) return null;
    return AppUser(
      uid: user.uid,
      email: user.email ?? '',
      fullName: user.displayName ?? 'User',
      createdAt: DateTime.now(),
    );
  }).value;
});

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
      // ← remove: _ref.read(currentUserProvider.notifier).state = user;
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
      // ← remove: _ref.read(currentUserProvider.notifier).state = user;
      state = const AsyncValue.data(null);
      return true;
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
      return false;
    }
  }

  Future<void> signOut() async {
    await _authService.signOut();
    // ← remove: _ref.read(currentUserProvider.notifier).state = null;
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

class CurrentUserNotifier extends StateNotifier<AppUser?> {
  CurrentUserNotifier() : super(null);

  void setUser(AppUser? user) => state = user;

  // Add this getter
  AppUser? get currentState => state;

  void updateName(String name) {
    if (state != null) state = state!.copyWith(fullName: name);
  }

  void updateDefaultCurrency(String code) {
    if (state != null) state = state!.copyWith(defaultCurrency: code);
  }
}

final currentUserNotifierProvider =
StateNotifierProvider<CurrentUserNotifier, AppUser?>((ref) {
  final notifier = CurrentUserNotifier();

  final initial = ref.read(currentUserProvider);
  notifier.setUser(initial);

  ref.listen<AppUser?>(currentUserProvider, (_, next) {
    if (next == null) {
      notifier.setUser(null);
    } else {
      final current = notifier.currentState;
      // Only reset if there's no existing local state (i.e. fresh sign-in)
      if (current == null) {
        notifier.setUser(next);
      }
      // Otherwise keep the locally updated state — don't overwrite it
    }
  });

  return notifier;
});