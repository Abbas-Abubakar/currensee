// lib/features/news/provider/news_provider.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:currensee/services/news_service.dart';
import 'package:currensee/models/news_article.dart';

// ─── Service Provider ─────────────────────────────────────────────────────
final newsServiceProvider = Provider<NewsService>((ref) => NewsService());

// ─── News category filter ─────────────────────────────────────────────────
enum NewsCategory { all, forex, business }

final newsCategoryProvider =
StateProvider<NewsCategory>((ref) => NewsCategory.all);

// ─── Currency news articles ───────────────────────────────────────────────
final currencyNewsProvider =
FutureProvider.autoDispose<List<NewsArticle>>((ref) async {
  final service = ref.watch(newsServiceProvider);
  return service.fetchCurrencyNews();
});

// ─── Business headlines ───────────────────────────────────────────────────
final forexHeadlinesProvider =
FutureProvider.autoDispose<List<NewsArticle>>((ref) async {
  final service = ref.watch(newsServiceProvider);
  return service.fetchForexHeadlines();
});

// ─── Filtered articles ────────────────────────────────────────────────────
final filteredNewsProvider =
Provider.autoDispose<AsyncValue<List<NewsArticle>>>((ref) {
  final category = ref.watch(newsCategoryProvider);
  final allNews = ref.watch(currencyNewsProvider);
  final headlines = ref.watch(forexHeadlinesProvider);

  switch (category) {
    case NewsCategory.forex:
      return allNews;
    case NewsCategory.business:
      return headlines;
    case NewsCategory.all:
      return allNews.whenData((articles) {
        final headlineList = headlines.valueOrNull ?? [];
        final combined = [...headlineList, ...articles];
        // Deduplicate by URL
        final seen = <String>{};
        return combined.where((a) => seen.add(a.url)).toList();
      });
  }
});