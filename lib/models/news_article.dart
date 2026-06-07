class NewsArticle {
  final String title;
  final String? description;
  final String? imageUrl;
  final String? author;
  final String sourceName;
  final String url;
  final DateTime publishedAt;

  const NewsArticle({
    required this.title,
    this.description,
    this.imageUrl,
    this.author,
    required this.sourceName,
    required this.url,
    required this.publishedAt,
  });

  factory NewsArticle.fromMap(Map<String, dynamic> map) {
    return NewsArticle(
      title: map['title'] as String? ?? 'No Title',
      description: map['description'] as String?,
      imageUrl: map['urlToImage'] as String?,
      author: map['author'] as String?,
      sourceName: (map['source'] as Map<String, dynamic>?)?['name']
      as String? ??
          'Unknown',
      url: map['url'] as String? ?? '',
      publishedAt: DateTime.tryParse(
          map['publishedAt'] as String? ?? '') ??
          DateTime.now(),
    );
  }
}