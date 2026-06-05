import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:currensee/providers/conversion_provider.dart';
import 'package:currensee/widgets/currency_picker_sheet.dart';
import 'package:currensee/providers/rates_provider.dart';
import 'package:currensee/screens/currency_detail_screen.dart';
import 'package:currensee/widgets/currency_list_tile.dart';

class RatesScreen extends ConsumerStatefulWidget {
  const RatesScreen({super.key});

  @override
  ConsumerState<RatesScreen> createState() => _RatesScreenState();
}

class _RatesScreenState extends ConsumerState<RatesScreen> {
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _showBasePicker() {
    final current = ref.read(baseCurrencyProvider);
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => CurrencyPickerSheet(
        selected: current,
        onSelected: (currency) {
          ref.read(baseCurrencyProvider.notifier).state = currency;
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final base = ref.watch(baseCurrencyProvider);
    final allRatesAsync = ref.watch(allRatesProvider);
    final filteredCurrencies = ref.watch(filteredCurrenciesProvider);
    final sortOption = ref.watch(sortOptionProvider);
    final searchQuery = ref.watch(currencySearchProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ─── Header ────────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Exchange Rates',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF202124),
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Live rates updated in real time',
                    style: TextStyle(
                      fontSize: 13,
                      color: Color(0xFF5F6368),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // ─── Base Currency Selector ──────────────────────────
                  GestureDetector(
                    onTap: _showBasePicker,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1A73E8),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            base.flagEmoji,
                            style: const TextStyle(fontSize: 20),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Base: ${base.code}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(width: 6),
                          const Icon(Icons.keyboard_arrow_down,
                              color: Colors.white, size: 18),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // ─── Search Bar ──────────────────────────────────────
                  TextField(
                    controller: _searchController,
                    onChanged: (val) =>
                    ref.read(currencySearchProvider.notifier).state = val,
                    decoration: InputDecoration(
                      hintText: 'Search currencies...',
                      prefixIcon:
                      const Icon(Icons.search, color: Colors.grey),
                      suffixIcon: searchQuery.isNotEmpty
                          ? IconButton(
                        icon: const Icon(Icons.clear, color: Colors.grey),
                        onPressed: () {
                          _searchController.clear();
                          ref
                              .read(currencySearchProvider.notifier)
                              .state = '';
                        },
                      )
                          : null,
                    ),
                  ),

                  const SizedBox(height: 12),

                  // ─── Sort Options ────────────────────────────────────
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: SortOption.values.map((option) {
                        final labels = {
                          SortOption.alphabetical: 'A → Z',
                          SortOption.rateHighToLow: 'Rate: High → Low',
                          SortOption.rateLowToHigh: 'Rate: Low → High',
                        };
                        final isSelected = sortOption == option;
                        return Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: FilterChip(
                            label: Text(labels[option]!),
                            selected: isSelected,
                            onSelected: (_) => ref
                                .read(sortOptionProvider.notifier)
                                .state = option,
                            selectedColor: const Color(0xFF1A73E8),
                            labelStyle: TextStyle(
                              color: isSelected
                                  ? Colors.white
                                  : const Color(0xFF202124),
                              fontWeight: isSelected
                                  ? FontWeight.w600
                                  : FontWeight.normal,
                              fontSize: 12,
                            ),
                            checkmarkColor: Colors.white,
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 8),

            // ─── Currency List ──────────────────────────────────────────
            Expanded(
              child: allRatesAsync.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, _) => Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.wifi_off, size: 48, color: Colors.grey),
                      const SizedBox(height: 12),
                      Text(
                        e.toString().replaceAll('Exception: ', ''),
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: Colors.grey),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton.icon(
                        onPressed: () =>
                            ref.invalidate(allRatesProvider),
                        icon: const Icon(Icons.refresh),
                        label: const Text('Retry'),
                        style: ElevatedButton.styleFrom(
                            minimumSize: const Size(120, 44)),
                      ),
                    ],
                  ),
                ),
                data: (rates) => filteredCurrencies.isEmpty
                    ? const Center(
                  child: Text(
                    'No currencies match your search.',
                    style: TextStyle(color: Colors.grey),
                  ),
                )
                    : ListView.builder(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
                  itemCount: filteredCurrencies.length,
                  itemBuilder: (context, index) {
                    final currency = filteredCurrencies[index];
                    final rate = rates[currency.code];

                    return CurrencyListTile(
                      currency: currency,
                      rate: rate,
                      baseCurrencyCode: base.code,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => CurrencyDetailScreen(
                              currency: currency,
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}