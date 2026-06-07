
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:currensee/services/alerts_service.dart';
import 'package:currensee/providers/auth_provider.dart';
import 'package:currensee/models/rate_alert.dart';

// ─── Service Provider ─────────────────────────────────────────────────────
final alertsServiceProvider = Provider<AlertsService>((ref) {
  return AlertsService();
});

// ─── Alerts list ──────────────────────────────────────────────────────────
final alertsProvider =
FutureProvider.autoDispose<List<RateAlert>>((ref) async {
  final user = ref.watch(currentUserProvider);
  if (user == null) return [];
  final service = ref.watch(alertsServiceProvider);
  return service.getAlerts(user.uid);
});

// ─── Alerts Notifier ──────────────────────────────────────────────────────
class AlertsNotifier extends StateNotifier<AsyncValue<void>> {
  final AlertsService _service;
  final Ref _ref;

  AlertsNotifier(this._service, this._ref)
      : super(const AsyncValue.data(null));

  Future<bool> createAlert({
    required String baseCurrency,
    required String targetCurrency,
    required double targetRate,
    required bool isAbove,
  }) async {
    final user = _ref.read(currentUserProvider);
    print('createAlert called, user: $user');
    if (user == null) return false;

    state = const AsyncValue.loading();
    try {
      final alert = RateAlert(
        uid: user.uid,
        baseCurrency: baseCurrency,
        targetCurrency: targetCurrency,
        targetRate: targetRate,
        isAbove: isAbove,
        createdAt: DateTime.now(),
      );
      await _service.createAlert(alert);
      _ref.invalidate(alertsProvider);
      state = const AsyncValue.data(null);
      return true;
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
      return false;
    }
  }

  Future<void> toggleAlert(int id, bool isActive) async {
    await _service.toggleAlert(id, isActive);
    _ref.invalidate(alertsProvider);
  }

  Future<void> deleteAlert(int id) async {
    await _service.deleteAlert(id);
    _ref.invalidate(alertsProvider);
  }

  Future<void> deleteAll() async {
    final user = _ref.read(currentUserProvider);
    if (user == null) return;
    await _service.deleteAllAlerts(user.uid);
    _ref.invalidate(alertsProvider);
  }

  Future<void> checkAlerts() async {
    final user = _ref.read(currentUserProvider);
    if (user == null) return;
    await _service.checkAlerts(user.uid);
    _ref.invalidate(alertsProvider);
  }

  String? getErrorMessage() {
    return state.maybeWhen(
      error: (e, _) => e.toString(),
      orElse: () => null,
    );
  }
}

final alertsNotifierProvider =
StateNotifierProvider<AlertsNotifier, AsyncValue<void>>((ref) {
  return AlertsNotifier(ref.watch(alertsServiceProvider), ref);
});