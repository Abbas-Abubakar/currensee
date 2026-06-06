// lib/features/history/provider/history_provider.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:currensee/providers/auth_provider.dart';
import 'package:currensee/services/history_service.dart';
import 'package:currensee/models/conversion_result.dart';

// ─── Service Provider ─────────────────────────────────────────────────────
final historyServiceProvider = Provider<HistoryService>((ref) {
  return HistoryService();
});

// ─── Filter state ─────────────────────────────────────────────────────────
final historyBaseFilterProvider = StateProvider<String>((ref) => '');
final historyTargetFilterProvider = StateProvider<String>((ref) => '');

// ─── History list ─────────────────────────────────────────────────────────
final historyProvider =
FutureProvider.autoDispose<List<ConversionResult>>((ref) async {
  final user = ref.watch(currentUserProvider);
  if (user == null) return [];

  final service = ref.watch(historyServiceProvider);
  final baseFilter = ref.watch(historyBaseFilterProvider);
  final targetFilter = ref.watch(historyTargetFilterProvider);

  return service.getFilteredHistory(
    uid: user.uid,
    baseCurrency: baseFilter.isNotEmpty ? baseFilter : null,
    targetCurrency: targetFilter.isNotEmpty ? targetFilter : null,
  );
});

// ─── Used currencies (for filter dropdowns) ───────────────────────────────
final usedBaseCurrenciesProvider =
FutureProvider.autoDispose<List<String>>((ref) async {
  final user = ref.watch(currentUserProvider);
  if (user == null) return [];
  final service = ref.watch(historyServiceProvider);
  return service.getUsedBaseCurrencies(user.uid);
});

final usedTargetCurrenciesProvider =
FutureProvider.autoDispose<List<String>>((ref) async {
  final user = ref.watch(currentUserProvider);
  if (user == null) return [];
  final service = ref.watch(historyServiceProvider);
  return service.getUsedTargetCurrencies(user.uid);
});

// ─── History Notifier (delete actions) ───────────────────────────────────
class HistoryNotifier extends StateNotifier<AsyncValue<void>> {
  final HistoryService _service;
  final Ref _ref;

  HistoryNotifier(this._service, this._ref)
      : super(const AsyncValue.data(null));

  Future<void> deleteEntry(int id) async {
    await _service.deleteEntry(id);
    _ref.invalidate(historyProvider);
    _ref.invalidate(usedBaseCurrenciesProvider);
    _ref.invalidate(usedTargetCurrenciesProvider);
  }

  Future<void> clearAll() async {
    final user = _ref.read(currentUserProvider);
    if (user == null) return;
    await _service.clearAllHistory(user.uid);
    // Reset filters
    _ref.read(historyBaseFilterProvider.notifier).state = '';
    _ref.read(historyTargetFilterProvider.notifier).state = '';
    _ref.invalidate(historyProvider);
    _ref.invalidate(usedBaseCurrenciesProvider);
    _ref.invalidate(usedTargetCurrenciesProvider);
  }
}

final historyNotifierProvider =
StateNotifierProvider<HistoryNotifier, AsyncValue<void>>((ref) {
  return HistoryNotifier(ref.watch(historyServiceProvider), ref);
});