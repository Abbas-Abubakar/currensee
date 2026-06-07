import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:currensee/providers/auth_provider.dart';
import 'package:currensee/providers/conversion_provider.dart';
import 'package:currensee/services/profile_service.dart';
import 'package:currensee/models/currency.dart';

// ─── Service Provider ─────────────────────────────────────────────────────
final profileServiceProvider = Provider<ProfileService>((ref) {
  return ProfileService();
});

// ─── Dark mode state ──────────────────────────────────────────────────────
final isDarkModeProvider = StateProvider<bool>((ref) => false);

// ─── Load preferences on startup ─────────────────────────────────────────
final preferencesLoaderProvider = FutureProvider<void>((ref) async {
  final service = ref.watch(profileServiceProvider);

  final isDark = await service.getIsDarkMode();
  ref.read(isDarkModeProvider.notifier).state = isDark;

  final currencyCode = await service.getDefaultCurrency();
  final currency = CurrencyList.findByCode(currencyCode);
  if (currency != null) {
    ref.read(baseCurrencyProvider.notifier).state = currency;
  }
});

// ─── Profile Notifier ─────────────────────────────────────────────────────
class ProfileNotifier extends StateNotifier<AsyncValue<void>> {
  final ProfileService _service;
  final Ref _ref;

  ProfileNotifier(this._service, this._ref)
      : super(const AsyncValue.data(null));

  Future<void> saveDefaultCurrency(String currencyCode) async {
    state = const AsyncValue.loading();
    try {
      await _service.saveDefaultCurrency(currencyCode);

      final currency = CurrencyList.findByCode(currencyCode);
      if (currency != null) {
        _ref.read(baseCurrencyProvider.notifier).state = currency;
      }

      // Update local user state so ProfileHeader rebuilds
      _ref.read(currentUserNotifierProvider.notifier)
          .updateDefaultCurrency(currencyCode);

      state = const AsyncValue.data(null);
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
    }
  }

  Future<void> toggleDarkMode(bool isDark) async {
    _ref.read(isDarkModeProvider.notifier).state = isDark;
    await _service.saveThemeMode(isDark);
  }

  Future<bool> updateDisplayName(String newName) async {
    if (newName.trim().isEmpty) return false;

    state = const AsyncValue.loading();
    try {
      final currentUser = _ref.read(currentUserNotifierProvider);
      if (currentUser == null) return false;

      await _service.updateDisplayName(
        uid: currentUser.uid,
        newName: newName.trim(),
      );

      _ref.read(currentUserNotifierProvider.notifier).updateName(newName.trim());

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

final profileNotifierProvider =
StateNotifierProvider<ProfileNotifier, AsyncValue<void>>((ref) {
  return ProfileNotifier(ref.watch(profileServiceProvider), ref);
});