
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:currensee/models/currency.dart';
import 'package:currensee/models/rate_alert.dart';

class AlertTile extends StatelessWidget {
  final RateAlert alert;
  final VoidCallback onDelete;
  final ValueChanged<bool> onToggle;

  const AlertTile({
    super.key,
    required this.alert,
    required this.onDelete,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    final formatter = NumberFormat('#,##0.####');
    final baseCurrency = CurrencyList.findByCode(alert.baseCurrency);
    final targetCurrency = CurrencyList.findByCode(alert.targetCurrency);

    return Dismissible(
      key: Key('alert_${alert.id}'),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(
          color: Colors.red.shade400,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(Icons.delete_outline, color: Theme.of(context).cardTheme.color ?? Theme.of(context).colorScheme.surface, size: 26),
      ),
      confirmDismiss: (_) async {
        return await showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16)),
            title: const Text('Delete Alert'),
            content: const Text('Remove this rate alert?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(ctx, true),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  minimumSize: const Size(80, 40),
                ),
                child: const Text('Delete'),
              ),
            ],
          ),
        );
      },
      onDismissed: (_) => onDelete(),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Theme.of(context).cardTheme.color ?? Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: alert.isActive
                ? const Color(0xFF1A73E8).withValues(alpha: 0.2)
                : Colors.grey.shade200,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            // ─── Flag Stack ─────────────────────────────────────────────
            SizedBox(
              width: 44,
              height: 44,
              child: Stack(
                children: [
                  Positioned(
                    top: 0,
                    left: 0,
                    child: Text(
                      baseCurrency?.flagEmoji ?? '🏳',
                      style: const TextStyle(fontSize: 22),
                    ),
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Text(
                      targetCurrency?.flagEmoji ?? '🏳',
                      style: const TextStyle(fontSize: 22),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(width: 14),

            // ─── Alert Info ──────────────────────────────────────────────
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${alert.baseCurrency} / ${alert.targetCurrency}',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(
                        alert.isAbove
                            ? Icons.arrow_upward
                            : Icons.arrow_downward,
                        size: 14,
                        color: alert.isAbove
                            ? const Color(0xFF34A853)
                            : const Color(0xFFEA4335),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${alert.isAbove ? 'Above' : 'Below'} ${formatter.format(alert.targetRate)}',
                        style: TextStyle(
                          fontSize: 13,
                          color: alert.isAbove
                              ? const Color(0xFF34A853)
                              : const Color(0xFFEA4335),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Created ${DateFormat('MMM dd, yyyy').format(alert.createdAt)}',
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.grey.shade500,
                    ),
                  ),
                ],
              ),
            ),

            // ─── Active Toggle ────────────────────────────────────────────
            Column(
              children: [
                Switch(
                  value: alert.isActive,
                  onChanged: onToggle,
                  activeColor: const Color(0xFF1A73E8),
                ),
                Text(
                  alert.isActive ? 'Active' : 'Off',
                  style: TextStyle(
                    fontSize: 10,
                    color: alert.isActive
                        ? const Color(0xFF1A73E8)
                        : Colors.grey,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}