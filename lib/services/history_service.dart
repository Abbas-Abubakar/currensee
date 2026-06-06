import 'package:currensee/database/app_database.dart';
import 'package:currensee/models/conversion_result.dart';

class HistoryService {
  final AppDatabase _db;

  HistoryService({AppDatabase? db}) : _db = db ?? AppDatabase.instance;

  // ─── Fetch all history for a user ────────────────────────────────────────
  Future<List<ConversionResult>> getHistory(String uid) async {
    final db = await _db.database;
    final maps = await db.query(
      'conversion_history',
      where: 'uid = ?',
      whereArgs: [uid],
      orderBy: 'date DESC',
    );
    return maps.map((m) => ConversionResult.fromMap(m)).toList();
  }

  // ─── Fetch filtered history by currency pair ──────────────────────────────
  Future<List<ConversionResult>> getFilteredHistory({
    required String uid,
    String? baseCurrency,
    String? targetCurrency,
  }) async {
    final db = await _db.database;

    String where = 'uid = ?';
    List<dynamic> whereArgs = [uid];

    if (baseCurrency != null && baseCurrency.isNotEmpty) {
      where += ' AND base_currency = ?';
      whereArgs.add(baseCurrency);
    }

    if (targetCurrency != null && targetCurrency.isNotEmpty) {
      where += ' AND target_currency = ?';
      whereArgs.add(targetCurrency);
    }

    final maps = await db.query(
      'conversion_history',
      where: where,
      whereArgs: whereArgs,
      orderBy: 'date DESC',
    );

    return maps.map((m) => ConversionResult.fromMap(m)).toList();
  }

  // ─── Delete a single entry by id ─────────────────────────────────────────
  Future<void> deleteEntry(int id) async {
    final db = await _db.database;
    await db.delete(
      'conversion_history',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // ─── Clear all history for a user ────────────────────────────────────────
  Future<void> clearAllHistory(String uid) async {
    final db = await _db.database;
    await db.delete(
      'conversion_history',
      where: 'uid = ?',
      whereArgs: [uid],
    );
  }

  // ─── Get unique currency pairs used by the user ───────────────────────────
  Future<List<String>> getUsedBaseCurrencies(String uid) async {
    final db = await _db.database;
    final result = await db.rawQuery(
      'SELECT DISTINCT base_currency FROM conversion_history WHERE uid = ? ORDER BY base_currency',
      [uid],
    );
    return result.map((r) => r['base_currency'] as String).toList();
  }

  Future<List<String>> getUsedTargetCurrencies(String uid) async {
    final db = await _db.database;
    final result = await db.rawQuery(
      'SELECT DISTINCT target_currency FROM conversion_history WHERE uid = ? ORDER BY target_currency',
      [uid],
    );
    return result.map((r) => r['target_currency'] as String).toList();
  }
}