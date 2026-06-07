// lib/features/news/service/news_service.dart

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:currensee/core/constants/api_constants.dart';
import 'package:currensee/models/news_article.dart';

class NewsService {
  // ─── Fetch currency news ──────────────────────────────────────────────────
  Future<List<NewsArticle>> fetchCurrencyNews() async {
    final url = Uri.parse(
      '${ApiConstants.newsApiBaseUrl}/everything'
          '?q=currency+exchange+rate+forex'
          '&language=en'
          '&sortBy=publishedAt'
          '&pageSize=20'
          '&apiKey=${ApiConstants.newsApiKey}',
    );

    final response = await http.get(url);

    if (response.statusCode != 200) {
      throw Exception('Failed to load news. Please try again.');
    }

    final data = jsonDecode(response.body) as Map<String, dynamic>;

    if (data['status'] != 'ok') {
      throw Exception(data['message'] ?? 'News API error.');
    }

    final articles = data['articles'] as List<dynamic>;

    return articles
        .map((a) => NewsArticle.fromMap(a as Map<String, dynamic>))
        .where((a) =>
    a.title != '[Removed]' &&
        a.url.isNotEmpty &&
        a.title.isNotEmpty)
        .toList();
  }

  // ─── Fetch top forex headlines ────────────────────────────────────────────
  Future<List<NewsArticle>> fetchForexHeadlines() async {
    final url = Uri.parse(
      '${ApiConstants.newsApiBaseUrl}/top-headlines'
          '?category=business'
          '&language=en'
          '&pageSize=5'
          '&apiKey=${ApiConstants.newsApiKey}',
    );

    final response = await http.get(url);

    if (response.statusCode != 200) {
      throw Exception('Failed to load headlines.');
    }

    final data = jsonDecode(response.body) as Map<String, dynamic>;
    if (data['status'] != 'ok') throw Exception(data['message']);

    final articles = data['articles'] as List<dynamic>;
    return articles
        .map((a) => NewsArticle.fromMap(a as Map<String, dynamic>))
        .where((a) => a.title != '[Removed]' && a.url.isNotEmpty)
        .toList();
  }
}