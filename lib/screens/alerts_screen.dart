import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:currensee/providers/alerts_provider.dart';
import 'package:currensee/widgets/add_alert_sheet.dart';
import 'package:currensee/widgets/alert_tile.dart';
import 'package:currensee/widgets/empty_alerts.dart';

class AlertsScreen extends ConsumerWidget {
  const AlertsScreen({super.key});

  void _showAddAlertSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const AddAlertSheet(),
    );
  }

  void _showDeleteAllDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape:
        RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Delete All Alerts'),
        content: const Text(
            'This will permanently remove all your rate alerts.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              ref.read(alertsNotifierProvider.notifier).deleteAll();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              minimumSize: const Size(80, 40),
            ),
            child: const Text('Delete All'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final alertsAsync = ref.watch(alertsProvider);
    final checkState = ref.watch(alertsNotifierProvider);
    final isChecking = checkState is AsyncLoading;

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ─── Header ────────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Rate Alerts',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                      ),
                      Text(
                        'Get notified at your target rate',
                        style: TextStyle(
                          fontSize: 13,
                          color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      // Check now button
                      IconButton(
                        icon: isChecking
                            ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                              strokeWidth: 2),
                        )
                            : const Icon(Icons.refresh),
                        onPressed: isChecking
                            ? null
                            : () => ref
                            .read(alertsNotifierProvider.notifier)
                            .checkAlerts(),
                        tooltip: 'Check rates now',
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete_sweep_outlined),
                        onPressed: () =>
                            _showDeleteAllDialog(context, ref),
                        tooltip: 'Delete all',
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // ─── Info banner ──────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
              child: Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: const Color(0xFF1A73E8).withOpacity(0.07),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.info_outline,
                        size: 16, color: Color(0xFF1A73E8)),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Tap the refresh icon to check your alerts against live rates.',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.blue.shade700,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 12),

            // ─── Alerts List ──────────────────────────────────────────
            Expanded(
              child: alertsAsync.when(
                loading: () =>
                const Center(child: CircularProgressIndicator()),
                error: (e, _) => Center(
                  child: Text(
                    'Error loading alerts.\n${e.toString()}',
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.grey),
                  ),
                ),
                data: (alerts) {
                  if (alerts.isEmpty) return const EmptyAlerts();

                  return ListView.builder(
                    padding:
                    const EdgeInsets.fromLTRB(20, 0, 20, 100),
                    itemCount: alerts.length,
                    itemBuilder: (context, index) {
                      final alert = alerts[index];
                      return AlertTile(
                        alert: alert,
                        onDelete: () => ref
                            .read(alertsNotifierProvider.notifier)
                            .deleteAlert(alert.id!),
                        onToggle: (val) => ref
                            .read(alertsNotifierProvider.notifier)
                            .toggleAlert(alert.id!, val),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),

      // ─── FAB ───────────────────────────────────────────────────────
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddAlertSheet(context),
        backgroundColor: const Color(0xFF1A73E8),
        icon: const Icon(Icons.add_alert, color: Colors.white),
        label: const Text(
          'New Alert',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }
}