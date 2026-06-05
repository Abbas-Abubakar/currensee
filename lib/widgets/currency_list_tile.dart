
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:currensee/models/currency.dart';

class CurrencyListTile extends StatelessWidget {
  final Currency currency;
  final double? rate;
  final String baseCurrencyCode;
  final VoidCallback onTap;

  const CurrencyListTile({
    super.key,
    required this.currency,
    required this.rate,
    required this.baseCurrencyCode,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final formatter = NumberFormat('#,##0.####');

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        margin: const EdgeInsets.only(bottom: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
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
            // ─── Flag ───────────────────────────────────────────────────
            Text(currency.flagEmoji, style: const TextStyle(fontSize: 30)),

            const SizedBox(width: 14),

            // ─── Code & Name ─────────────────────────────────────────────
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    currency.code,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                      color: Color(0xFF202124),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    currency.name,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF5F6368),
                    ),
                  ),
                ],
              ),
            ),

            // ─── Rate ────────────────────────────────────────────────────
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                rate != null
                    ? Text(
                  formatter.format(rate),
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                    color: Color(0xFF202124),
                  ),
                )
                    : Container(
                  width: 60,
                  height: 14,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '1 $baseCurrencyCode',
                  style: const TextStyle(
                    fontSize: 11,
                    color: Color(0xFF5F6368),
                  ),
                ),
              ],
            ),

            const SizedBox(width: 8),
            const Icon(Icons.chevron_right, color: Colors.grey, size: 20),
          ],
        ),
      ),
    );
  }
}