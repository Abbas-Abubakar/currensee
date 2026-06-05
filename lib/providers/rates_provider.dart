import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:currensee/services/rates_service.dart';
import 'package:currensee/providers/conversion_provider.dart';
import 'package:currensee/models/currency.dart';

// ─── Service Provider ─────────────────────────────────────────────────────
final ratesServiceProvider = Provider<RatesService>((ref) => RatesService());

// ─── Search query state ───────────────────────────────────────────────────
final currencySearchProvider = StateProvider<String>((ref) => '');

// ─── Sort option ──────────────────────────────────────────────────────────
enum SortOption { alphabetical, rateHighToLow, rateLowToHigh }

final sortOptionProvider =
StateProvider<SortOption>((ref) => SortOption.alphabetical);

// ─── All rates for the selected base currency ─────────────────────────────
final allRatesProvider =
FutureProvider.autoDispose<Map<String, double>>((ref) async {
  final base = ref.watch(baseCurrencyProvider);
  final service = ref.watch(ratesServiceProvider);
  return service.fetchAllRates(base.code);
});

// ─── Filtered + sorted currency list ─────────────────────────────────────
final filteredCurrenciesProvider = Provider<List<Currency>>((ref) {
  final query = ref.watch(currencySearchProvider).toLowerCase();
  final sortOption = ref.watch(sortOptionProvider);
  final ratesAsync = ref.watch(allRatesProvider);

  List<Currency> currencies = List.from(CurrencyList.all);

  // Filter by search
  if (query.isNotEmpty) {
    currencies = currencies
        .where((c) =>
    c.code.toLowerCase().contains(query) ||
        c.name.toLowerCase().contains(query))
        .toList();
  }

  // Sort
  ratesAsync.whenData((rates) {
    switch (sortOption) {
      case SortOption.alphabetical:
        currencies.sort((a, b) => a.code.compareTo(b.code));
        break;
      case SortOption.rateHighToLow:
        currencies.sort((a, b) {
          final rateA = rates[a.code] ?? 0;
          final rateB = rates[b.code] ?? 0;
          return rateB.compareTo(rateA);
        });
        break;
      case SortOption.rateLowToHigh:
        currencies.sort((a, b) {
          final rateA = rates[a.code] ?? 0;
          final rateB = rates[b.code] ?? 0;
          return rateA.compareTo(rateB);
        });
        break;
    }
  });

  // Always sort alphabetically as fallback when rates not loaded
  if (ratesAsync is! AsyncData) {
    currencies.sort((a, b) => a.code.compareTo(b.code));
  }

  return currencies;
});

// ─── Single currency detail provider ─────────────────────────────────────
final currencyDetailProvider =
FutureProvider.autoDispose.family<Map<String, dynamic>, String>(
      (ref, targetCode) async {
    final base = ref.watch(baseCurrencyProvider);
    final service = ref.watch(ratesServiceProvider);

    final rate = await service.fetchSingleRate(
      base: base.code,
      target: targetCode,
    );

    final history = service.generateMockHistory(rate);

    return {
      'rate': rate,
      'history': history,
      'base': base.code,
      'target': targetCode,
    };
  },
);