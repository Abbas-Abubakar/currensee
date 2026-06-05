
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:currensee/providers/conversion_provider.dart';
import 'package:currensee/providers/rates_provider.dart';
import 'package:currensee/widgets/rate_info_card.dart';
import 'package:currensee/models/currency.dart';

class CurrencyDetailScreen extends ConsumerWidget {
  final Currency currency;

  const CurrencyDetailScreen({super.key, required this.currency});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final base = ref.watch(baseCurrencyProvider);
    final detailAsync =
    ref.watch(currencyDetailProvider(currency.code));
    final formatter = NumberFormat('#,##0.######');

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(currency.flagEmoji,
                style: const TextStyle(fontSize: 20)),
            const SizedBox(width: 8),
            Text('${currency.code} / ${base.code}'),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () =>
                ref.invalidate(currencyDetailProvider(currency.code)),
          ),
        ],
      ),
      body: detailAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 48, color: Colors.grey),
              const SizedBox(height: 12),
              Text(
                e.toString().replaceAll('Exception: ', ''),
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () =>
                    ref.invalidate(currencyDetailProvider(currency.code)),
                style: ElevatedButton.styleFrom(
                    minimumSize: const Size(120, 44)),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
        data: (detail) {
          final rate = detail['rate'] as double;
          final history = detail['history'] as List<double>;
          final inverseRate = 1 / rate;

          final minRate =
          history.reduce((a, b) => a < b ? a : b);
          final maxRate =
          history.reduce((a, b) => a > b ? a : b);

          final isUp = history.last >= history[history.length - 2];

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ─── Hero Rate Card ──────────────────────────────────
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF1A73E8), Color(0xFF0D47A1)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            currency.flagEmoji,
                            style: const TextStyle(fontSize: 36),
                          ),
                          const SizedBox(width: 12),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                currency.name,
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.85),
                                  fontSize: 14,
                                ),
                              ),
                              Text(
                                currency.code,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      Text(
                        '1 ${base.code} =',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.7),
                          fontSize: 13,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            formatter.format(rate),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 36,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Padding(
                            padding: const EdgeInsets.only(bottom: 6),
                            child: Text(
                              currency.code,
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.8),
                                fontSize: 18,
                              ),
                            ),
                          ),
                          const Spacer(),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 5),
                            decoration: BoxDecoration(
                              color: isUp
                                  ? Colors.green.withOpacity(0.25)
                                  : Colors.red.withOpacity(0.25),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  isUp
                                      ? Icons.trending_up
                                      : Icons.trending_down,
                                  color: isUp
                                      ? Colors.greenAccent
                                      : Colors.redAccent,
                                  size: 16,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  isUp ? 'Up' : 'Down',
                                  style: TextStyle(
                                    color: isUp
                                        ? Colors.greenAccent
                                        : Colors.redAccent,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // ─── 30-Day Trend Chart ──────────────────────────────
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.04),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment:
                        MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            '30-Day Trend',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: Color(0xFF202124),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.grey.shade100,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: const Text(
                              'Simulated',
                              style: TextStyle(
                                fontSize: 10,
                                color: Colors.grey,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      SparklineChart(
                        data: history,
                        color: isUp
                            ? const Color(0xFF34A853)
                            : const Color(0xFFEA4335),
                        height: 80,
                      ),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment:
                        MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '30 days ago',
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.grey.shade500,
                            ),
                          ),
                          Text(
                            'Today',
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.grey.shade500,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // ─── Stats Grid ──────────────────────────────────────
                const Text(
                  'Rate Statistics',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF202124),
                  ),
                ),
                const SizedBox(height: 12),
                GridView.count(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: 2,
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  childAspectRatio: 1.6,
                  children: [
                    RateInfoCard(
                      label: 'Current Rate',
                      value: formatter.format(rate),
                      icon: Icons.currency_exchange,
                      iconColor: const Color(0xFF1A73E8),
                    ),
                    RateInfoCard(
                      label: 'Inverse Rate',
                      value: formatter.format(inverseRate),
                      icon: Icons.swap_horiz,
                      iconColor: const Color(0xFF34A853),
                    ),
                    RateInfoCard(
                      label: '30D Low',
                      value: formatter.format(minRate),
                      icon: Icons.arrow_downward,
                      iconColor: const Color(0xFFEA4335),
                    ),
                    RateInfoCard(
                      label: '30D High',
                      value: formatter.format(maxRate),
                      icon: Icons.arrow_upward,
                      iconColor: const Color(0xFF34A853),
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                // ─── Currency Info ───────────────────────────────────
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.04),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Currency Info',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                          color: Color(0xFF202124),
                        ),
                      ),
                      const SizedBox(height: 12),
                      _InfoRow(
                          label: 'Full Name', value: currency.name),
                      _InfoRow(label: 'Code', value: currency.code),
                      _InfoRow(
                          label: 'Symbol', value: currency.symbol),
                      _InfoRow(
                        label: 'Last Updated',
                        value: DateFormat('MMM dd, yyyy • hh:mm a')
                            .format(DateTime.now()),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 30),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;

  const _InfoRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 13,
              color: Color(0xFF5F6368),
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: Color(0xFF202124),
            ),
          ),
        ],
      ),
    );
  }
}