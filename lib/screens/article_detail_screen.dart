import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:currensee/models/news_article.dart';

class ArticleDetailScreen extends StatefulWidget {
  final NewsArticle article;

  const ArticleDetailScreen({super.key, required this.article});

  @override
  State<ArticleDetailScreen> createState() => _ArticleDetailScreenState();
}

class _ArticleDetailScreenState extends State<ArticleDetailScreen> {
  late final WebViewController _controller;
  bool _isLoading = true;
  int _loadingProgress = 0;

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (_) => setState(() => _isLoading = true),
          onPageFinished: (_) => setState(() => _isLoading = false),
          onProgress: (progress) =>
              setState(() => _loadingProgress = progress),
        ),
      )
      ..loadRequest(Uri.parse(widget.article.url));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.article.sourceName,
          style: const TextStyle(fontSize: 16),
        ),
        actions: [
          if (_isLoading)
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                '$_loadingProgress%',
                style: const TextStyle(
                    color: Colors.white, fontSize: 12),
              ),
            ),
        ],
      ),
      body: Stack(
        children: [
          WebViewWidget(controller: _controller),
          if (_isLoading)
            LinearProgressIndicator(
              value: _loadingProgress / 100,
              backgroundColor: Colors.transparent,
              color: Colors.white,
            ),
        ],
      ),
    );
  }
}