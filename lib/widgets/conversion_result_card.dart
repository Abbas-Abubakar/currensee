// lib/features/conversion/view/widgets/conversion_result_card.dart

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:currensee/models/conversion_result.dart';

class ConversionResultCard extends StatelessWidget {
  final ConversionResult result;

  const ConversionResultCard({super.key, required this.result});

  @override
  Widget build(BuildContext context) {
    final formatter = NumberFormat('#,##0.####');

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1A73E8), Color(0xFF0D47A1)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF1A73E8).withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ─── You Send ─────────────────────────────────────────────────
          Text(
            'You send',
            style: TextStyle(
              color: Colors.white.withOpacity(0.8),
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '${formatter.format(result.amount)} ${result.baseCurrency}',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.w600,
            ),
          ),

          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Divider(color: Colors.white.withOpacity(0.3)),
          ),

          // ─── You Receive ──────────────────────────────────────────────
          Text(
            'You receive',
            style: TextStyle(
              color: Colors.white.withOpacity(0.8),
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '${formatter.format(result.convertedAmount)} ${result.targetCurrency}',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 30,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 16),

          // ─── Rate ─────────────────────────────────────────────────────
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.trending_up, color: Colors.white, size: 16),
                const SizedBox(width: 6),
                Text(
                  '1 ${result.baseCurrency} = ${formatter.format(result.exchangeRate)} ${result.targetCurrency}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 8),

          // ─── Timestamp ────────────────────────────────────────────────
          Text(
            'Rate as of ${DateFormat('MMM dd, yyyy • hh:mm a').format(result.date)}',
            style: TextStyle(
              color: Colors.white.withOpacity(0.6),
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }
}