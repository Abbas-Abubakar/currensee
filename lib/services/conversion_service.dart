import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:currensee/core/constants/api_constants.dart';
import 'package:currensee/database/app_database.dart';
import 'package:currensee/models/conversion_result.dart';

class ConversionService {
  final AppDatabase _db;

  ConversionService({AppDatabase? db}) : _db = db ?? AppDatabase.instance;

  // ─── Fetch live exchange rates for a base currency ───────────────────────
  Future<Map<String, double>> fetchRates(String baseCurrency) async {
    final url =
        '${ApiConstants.exchangeRateBaseUrl}/${ApiConstants.exchangeRateApiKey}/latest/$baseCurrency';

    final response = await http.get(Uri.parse(url));

    if (response.statusCode != 200) {
      throw Exception('Failed to fetch exchange rates. Please try again.');
    }

    final data = jsonDecode(response.body) as Map<String, dynamic>;

    if (data['result'] != 'success') {
      throw Exception(data['error-type'] ?? 'Unknown API error');
    }

    final rates = data['conversion_rates'] as Map<String, dynamic>;
    return rates.map((key, value) => MapEntry(key, (value as num).toDouble()));
  }

  // ─── Convert amount ───────────────────────────────────────────────────────
  Future<ConversionResult> convert({
    required String baseCurrency,
    required String targetCurrency,
    required double amount,
  }) async {
    final rates = await fetchRates(baseCurrency);

    final rate = rates[targetCurrency];
    if (rate == null) {
      throw Exception('Target currency $targetCurrency not supported.');
    }

    final convertedAmount = amount * rate;

    return ConversionResult(
      baseCurrency: baseCurrency,
      targetCurrency: targetCurrency,
      amount: amount,
      convertedAmount: convertedAmount,
      exchangeRate: rate,
      date: DateTime.now(),
    );
  }

  // ─── Save conversion to SQLite history ───────────────────────────────────
  Future<void> saveToHistory({
    required ConversionResult result,
    required String uid,
  }) async {
    final db = await _db.database;
    await db.insert('conversion_history', result.toMap(uid));
  }

  // ─── Fetch user conversion history ───────────────────────────────────────
  Future<List<ConversionResult>> getHistory(String uid) async {
    final db = await _db.database;
    final maps = await db.query(
      'conversion_history',
      where: 'uid = ?',
      whereArgs: [uid],
      orderBy: 'date DESC',
      limit: 50,
    );
    return maps.map((m) => ConversionResult.fromMap(m)).toList();
  }
}