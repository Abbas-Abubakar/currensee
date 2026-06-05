
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:currensee/providers/auth_provider.dart';
import 'package:currensee/services/conversion_service.dart';
import 'package:currensee/models/conversion_result.dart';
import 'package:currensee/models/currency.dart';

// ─── Service Provider ─────────────────────────────────────────────────────
final conversionServiceProvider = Provider<ConversionService>((ref) {
  return ConversionService();
});

// ─── Selected Currencies ──────────────────────────────────────────────────
final baseCurrencyProvider = StateProvider<Currency>((ref) {
  return CurrencyList.findByCode('USD')!;
});

final targetCurrencyProvider = StateProvider<Currency>((ref) {
  return CurrencyList.findByCode('NGN')!;
});

// ─── Exchange Rates (fetched from API) ────────────────────────────────────
final exchangeRatesProvider =
FutureProvider.autoDispose.family<Map<String, double>, String>(
      (ref, baseCurrency) async {
    final service = ref.watch(conversionServiceProvider);
    return service.fetchRates(baseCurrency);
  },
);

// ─── Conversion State ─────────────────────────────────────────────────────
class ConversionState {
  final double amount;
  final ConversionResult? result;
  final bool isLoading;
  final String? errorMessage;

  const ConversionState({
    this.amount = 1.0,
    this.result,
    this.isLoading = false,
    this.errorMessage,
  });

  ConversionState copyWith({
    double? amount,
    ConversionResult? result,
    bool? isLoading,
    String? errorMessage,
  }) {
    return ConversionState(
      amount: amount ?? this.amount,
      result: result ?? this.result,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
    );
  }
}

// ─── Conversion Notifier ──────────────────────────────────────────────────
class ConversionNotifier extends StateNotifier<ConversionState> {
  final ConversionService _service;
  final Ref _ref;

  ConversionNotifier(this._service, this._ref)
      : super(const ConversionState());

  Future<void> convert({
    required String baseCurrency,
    required String targetCurrency,
    required double amount,
  }) async {
    if (amount <= 0) {
      state = state.copyWith(errorMessage: 'Enter a valid amount greater than 0');
      return;
    }

    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      final result = await _service.convert(
        baseCurrency: baseCurrency,
        targetCurrency: targetCurrency,
        amount: amount,
      );

      state = state.copyWith(
        result: result,
        amount: amount,
        isLoading: false,
      );

      // Save to history
      final currentUser = _ref.read(currentUserProvider);
      if (currentUser != null) {
        await _service.saveToHistory(result: result, uid: currentUser.uid);
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString().replaceAll('Exception: ', ''),
      );
    }
  }

  void swapCurrencies() {
    final base = _ref.read(baseCurrencyProvider);
    final target = _ref.read(targetCurrencyProvider);
    _ref.read(baseCurrencyProvider.notifier).state = target;
    _ref.read(targetCurrencyProvider.notifier).state = base;
    state = state.copyWith(result: null, errorMessage: null);
  }

  void clearResult() {
    state = state.copyWith(result: null, errorMessage: null);
  }
}

final conversionNotifierProvider =
StateNotifierProvider<ConversionNotifier, ConversionState>((ref) {
  return ConversionNotifier(ref.watch(conversionServiceProvider), ref);
});