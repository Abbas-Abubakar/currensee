import 'dart:convert';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:http/http.dart' as http;
import 'package:currensee/core/constants/api_constants.dart';
import 'package:currensee/database/app_database.dart';
import 'package:currensee/models/rate_alert.dart';

class AlertsService {
  final AppDatabase _db;
  final FlutterLocalNotificationsPlugin _notificationsPlugin;

  AlertsService({
    AppDatabase? db,
    FlutterLocalNotificationsPlugin? notificationsPlugin,
  })  : _db = db ?? AppDatabase.instance,
        _notificationsPlugin =
            notificationsPlugin ?? FlutterLocalNotificationsPlugin();

  // ─── Initialize local notifications ──────────────────────────────────────
  Future<void> initNotifications() async {
    const androidSettings =
    AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );
    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _notificationsPlugin.initialize(initSettings);
  }

  // ─── Show a local notification ────────────────────────────────────────────
  Future<void> showNotification({
    required int id,
    required String title,
    required String body,
  }) async {
    const androidDetails = AndroidNotificationDetails(
      'rate_alerts_channel',
      'Rate Alerts',
      channelDescription: 'Notifications for currency rate alerts',
      importance: Importance.high,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
    );
    const iosDetails = DarwinNotificationDetails();
    const details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _notificationsPlugin.show(id, title, body, details);
  }

  // ─── CRUD Operations ──────────────────────────────────────────────────────
  Future<List<RateAlert>> getAlerts(String uid) async {
    final db = await _db.database;
    final maps = await db.query(
      'rate_alerts',
      where: 'uid = ?',
      whereArgs: [uid],
      orderBy: 'created_at DESC',
    );
    return maps.map((m) => RateAlert.fromMap(m)).toList();
  }

  Future<RateAlert> createAlert(RateAlert alert) async {
    final db = await _db.database;
    final id = await db.insert('rate_alerts', alert.toMap());
    return alert.copyWith(id: id);
  }

  Future<void> toggleAlert(int id, bool isActive) async {
    final db = await _db.database;
    await db.update(
      'rate_alerts',
      {'is_active': isActive ? 1 : 0},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> deleteAlert(int id) async {
    final db = await _db.database;
    await db.delete(
      'rate_alerts',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> deleteAllAlerts(String uid) async {
    final db = await _db.database;
    await db.delete(
      'rate_alerts',
      where: 'uid = ?',
      whereArgs: [uid],
    );
  }

  // ─── Check alerts against live rates ─────────────────────────────────────
  Future<void> checkAlerts(String uid) async {
    final alerts = await getAlerts(uid);
    final activeAlerts = alerts.where((a) => a.isActive).toList();

    if (activeAlerts.isEmpty) return;

    // Group by base currency to minimize API calls
    final Map<String, List<RateAlert>> grouped = {};
    for (final alert in activeAlerts) {
      grouped.putIfAbsent(alert.baseCurrency, () => []).add(alert);
    }

    for (final entry in grouped.entries) {
      try {
        final rates = await _fetchRates(entry.key);

        for (final alert in entry.value) {
          final liveRate = rates[alert.targetCurrency];
          if (liveRate == null) continue;

          final triggered = alert.isAbove
              ? liveRate >= alert.targetRate
              : liveRate <= alert.targetRate;

          if (triggered) {
            final direction = alert.isAbove ? 'risen above' : 'fallen below';
            await showNotification(
              id: alert.id ?? 0,
              title: '🔔 Rate Alert: ${alert.baseCurrency}/${alert.targetCurrency}',
              body:
              '1 ${alert.baseCurrency} has $direction ${alert.targetRate} ${alert.targetCurrency}. Current rate: $liveRate',
            );

            // Deactivate alert after triggering
            if (alert.id != null) {
              await toggleAlert(alert.id!, false);
            }
          }
        }
      } catch (_) {
        // Skip silently if API fails for a base currency
        continue;
      }
    }
  }

  // ─── Private helpers ──────────────────────────────────────────────────────
  Future<Map<String, double>> _fetchRates(String baseCurrency) async {
    final url =
        '${ApiConstants.exchangeRateBaseUrl}/${ApiConstants.exchangeRateApiKey}/latest/$baseCurrency';
    final response = await http.get(Uri.parse(url));
    if (response.statusCode != 200) throw Exception('Failed to fetch rates');
    final data = jsonDecode(response.body) as Map<String, dynamic>;
    if (data['result'] != 'success') throw Exception('API error');
    final rates = data['conversion_rates'] as Map<String, dynamic>;
    return rates.map((k, v) => MapEntry(k, (v as num).toDouble()));
  }
}