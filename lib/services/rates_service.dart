// lib/features/rates/service/rates_service.dart

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:currensee/core/constants/api_constants.dart';

class RatesService {
  // ─── Fetch all rates for a base currency ─────────────────────────────────
  Future<Map<String, double>> fetchAllRates(String baseCurrency) async {
    final url =
        '${ApiConstants.exchangeRateBaseUrl}/${ApiConstants.exchangeRateApiKey}/latest/$baseCurrency';

    final response = await http.get(Uri.parse(url));

    if (response.statusCode != 200) {
      throw Exception('Failed to load rates. Please try again.');
    }

    final data = jsonDecode(response.body) as Map<String, dynamic>;

    if (data['result'] != 'success') {
      throw Exception(data['error-type'] ?? 'API error occurred.');
    }

    final rates = data['conversion_rates'] as Map<String, dynamic>;
    return rates.map((k, v) => MapEntry(k, (v as num).toDouble()));
  }

  // ─── Fetch rate for a single currency pair ────────────────────────────────
  Future<double> fetchSingleRate({
    required String base,
    required String target,
  }) async {
    final url =
        '${ApiConstants.exchangeRateBaseUrl}/${ApiConstants.exchangeRateApiKey}/pair/$base/$target';

    final response = await http.get(Uri.parse(url));

    if (response.statusCode != 200) {
      throw Exception('Failed to load rate.');
    }

    final data = jsonDecode(response.body) as Map<String, dynamic>;

    if (data['result'] != 'success') {
      throw Exception(data['error-type'] ?? 'API error occurred.');
    }

    return (data['conversion_rate'] as num).toDouble();
  }

  // ─── Simulate historical data (free tier has no history endpoint) ─────────
  // We generate plausible mock data around the live rate for the chart.
  // Replace with a paid API endpoint if available.
  List<double> generateMockHistory(double currentRate) {
    final random = <double>[];
    double value = currentRate * 0.95;
    final variance = currentRate * 0.01;

    for (int i = 0; i < 30; i++) {
      value += (variance * (i % 3 == 0 ? 1 : -0.5));
      value = value.clamp(currentRate * 0.90, currentRate * 1.10);
      random.add(double.parse(value.toStringAsFixed(4)));
    }
    random.add(currentRate);
    return random;
  }
}