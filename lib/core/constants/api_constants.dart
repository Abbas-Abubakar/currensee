class ApiConstants {
  ApiConstants._();

  static const exchangeRateApiKey = String.fromEnvironment('EXCHANGE_RATE_API_KEY', defaultValue: 'fallback_key');
  static const String exchangeRateBaseUrl =
      'https://v6.exchangerate-api.com/v6';

  // NewsAPI
  static const String newsApiKey = String.fromEnvironment('NEWS_API_KEY');
  static const String newsApiBaseUrl = 'https://newsapi.org/v2';
}