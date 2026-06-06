// lib/features/history/view/widgets/history_tile.dart

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:currensee/models/conversion_result.dart';
import 'package:currensee/models/currency.dart';

class HistoryTile extends StatelessWidget {
  final ConversionResult result;
  final VoidCallback onDelete;

  const HistoryTile({
    super.key,
    required this.result,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final amountFormatter = NumberFormat('#,##0.####');
    final dateFormatter = DateFormat('MMM dd, yyyy');
    final timeFormatter = DateFormat('hh:mm a');

    final baseCurrency = CurrencyList.findByCode(result.baseCurrency);
    final targetCurrency = CurrencyList.findByCode(result.targetCurrency);

    return Dismissible(
      key: Key('history_${result.id}'),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(
          color: Colors.red.shade400,
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Icon(Icons.delete_outline, color: Colors.white, size: 26),
      ),
      confirmDismiss: (_) async {
        return await showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
            shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            title: const Text('Delete Entry'),
            content:
            const Text('Remove this conversion from your history?'),
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
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            // ─── Flags ──────────────────────────────────────────────────
            Column(
              children: [
                Text(
                  baseCurrency?.flagEmoji ?? '🏳',
                  style: const TextStyle(fontSize: 22),
                ),
                const SizedBox(height: 2),
                const Icon(Icons.arrow_downward,
                    size: 12, color: Colors.grey),
                const SizedBox(height: 2),
                Text(
                  targetCurrency?.flagEmoji ?? '🏳',
                  style: const TextStyle(fontSize: 22),
                ),
              ],
            ),

            const SizedBox(width: 14),

            // ─── Conversion Info ─────────────────────────────────────────
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Pair
                  Text(
                    '${result.baseCurrency} → ${result.targetCurrency}',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: Color(0xFF202124),
                    ),
                  ),
                  const SizedBox(height: 4),
                  // Amount converted
                  Text(
                    '${amountFormatter.format(result.amount)} ${result.baseCurrency}  =  ${amountFormatter.format(result.convertedAmount)} ${result.targetCurrency}',
                    style: const TextStyle(
                      fontSize: 13,
                      color: Color(0xFF5F6368),
                    ),
                  ),
                  const SizedBox(height: 4),
                  // Rate
                  Text(
                    'Rate: 1 ${result.baseCurrency} = ${amountFormatter.format(result.exchangeRate)} ${result.targetCurrency}',
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.grey.shade500,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(width: 8),

            // ─── Date & Time ─────────────────────────────────────────────
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  dateFormatter.format(result.date),
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF5F6368),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  timeFormatter.format(result.date),
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.grey.shade400,
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