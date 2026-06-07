// lib/features/news/view/news_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:currensee/providers/conversion_provider.dart';
import 'package:currensee/providers/news_provider.dart';
import 'package:currensee/screens/article_detail_screen.dart';
import 'package:currensee/widgets/news_card.dart';
import 'package:currensee/widgets/news_shimmer.dart';
import 'package:currensee/widgets/trend_summary_card.dart';

class NewsScreen extends ConsumerWidget {
  const NewsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filteredNews = ref.watch(filteredNewsProvider);
    final category = ref.watch(newsCategoryProvider);
    final ratesAsync = ref.watch(
      exchangeRatesProvider('USD'),
    );

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ─── Header ──────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Market News',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                      ),
                      Text(
                        'Currency & forex updates',
                        style: TextStyle(
                          fontSize: 13,
                          color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                        ),
                      ),
                    ],
                  ),
                  IconButton(
                    icon: const Icon(Icons.refresh),
                    onPressed: () {
                      ref.invalidate(currencyNewsProvider);
                      ref.invalidate(forexHeadlinesProvider);
                    },
                    tooltip: 'Refresh',
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // ─── Market Trend Summary ─────────────────────────────────
            ratesAsync.when(
              loading: () => const SizedBox(height: 100),
              error: (_, __) => const SizedBox.shrink(),
              data: (rates) {
                final pairs = [
                  ('EUR/USD', rates['EUR'], true),
                  ('GBP/USD', rates['GBP'], false),
                  ('NGN/USD', rates['NGN'], true),
                  ('JPY/USD', rates['JPY'], false),
                  ('AUD/USD', rates['AUD'], true),
                ];

                return SizedBox(
                  height: 100,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    padding:
                    const EdgeInsets.symmetric(horizontal: 20),
                    itemCount: pairs.length,
                    separatorBuilder: (_, __) =>
                    const SizedBox(width: 12),
                    itemBuilder: (_, index) {
                      final pair = pairs[index];
                      final rate = pair.$2;
                      return TrendSummaryCard(
                        pair: pair.$1,
                        rate: rate != null
                            ? rate.toStringAsFixed(4)
                            : '--',
                        change: pair.$3 ? '+0.12%' : '-0.08%',
                        isPositive: pair.$3,
                      );
                    },
                  ),
                );
              },
            ),

            const SizedBox(height: 16),

            // ─── Category Filter ──────────────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: NewsCategory.values.map((cat) {
                    final labels = {
                      NewsCategory.all: '🌐  All',
                      NewsCategory.forex: '💱  Forex',
                      NewsCategory.business: '📈  Business',
                    };
                    final isSelected = category == cat;
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: FilterChip(
                        label: Text(labels[cat]!),
                        selected: isSelected,
                        onSelected: (_) => ref
                            .read(newsCategoryProvider.notifier)
                            .state = cat,
                        selectedColor: const Color(0xFF1A73E8),
                        labelStyle: TextStyle(
                          color: isSelected
                              ? Theme.of(context).cardTheme.color ?? Theme.of(context).colorScheme.surface
                              : Theme.of(context).colorScheme.onSurface,
                          fontWeight: isSelected
                              ? FontWeight.w600
                              : FontWeight.normal,
                        ),
                        checkmarkColor: Theme.of(context).cardTheme.color ?? Theme.of(context).colorScheme.surface,
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),

            const SizedBox(height: 12),

            // ─── News List ────────────────────────────────────────────
            Expanded(
              child: filteredNews.when(
                loading: () => const NewsShimmer(),
                error: (e, _) => Center(
                  child: Padding(
                    padding: const EdgeInsets.all(32),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.wifi_off,
                            size: 48, color: Colors.grey),
                        const SizedBox(height: 12),
                        Text(
                          e
                              .toString()
                              .replaceAll('Exception: ', ''),
                          textAlign: TextAlign.center,
                          style:
                          const TextStyle(color: Colors.grey),
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton.icon(
                          onPressed: () {
                            ref.invalidate(currencyNewsProvider);
                            ref.invalidate(forexHeadlinesProvider);
                          },
                          icon: const Icon(Icons.refresh),
                          label: const Text('Retry'),
                          style: ElevatedButton.styleFrom(
                              minimumSize: const Size(120, 44)),
                        ),
                      ],
                    ),
                  ),
                ),
                data: (articles) => articles.isEmpty
                    ? const Center(
                  child: Text(
                    'No news articles found.',
                    style: TextStyle(color: Colors.grey),
                  ),
                )
                    : RefreshIndicator(
                  onRefresh: () async {
                    ref.invalidate(currencyNewsProvider);
                    ref.invalidate(forexHeadlinesProvider);
                  },
                  child: ListView.builder(
                    padding: const EdgeInsets.fromLTRB(
                        20, 0, 20, 100),
                    itemCount: articles.length,
                    itemBuilder: (context, index) {
                      final article = articles[index];
                      return NewsCard(
                        article: article,
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                ArticleDetailScreen(
                                  article: article,
                                ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}