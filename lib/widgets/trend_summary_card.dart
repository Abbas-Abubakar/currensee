// lib/features/news/view/widgets/trend_summary_card.dart

import 'package:flutter/material.dart';

class TrendSummaryCard extends StatelessWidget {
  final String pair;
  final String rate;
  final String change;
  final bool isPositive;

  const TrendSummaryCard({
    super.key,
    required this.pair,
    required this.rate,
    required this.change,
    required this.isPositive,
  });

  @override
  Widget build(BuildContext context) {
    final color =
    isPositive ? const Color(0xFF34A853) : const Color(0xFFEA4335);

    return Container(
      width: 140,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            pair,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            rate,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              Icon(
                isPositive ? Icons.arrow_upward : Icons.arrow_downward,
                size: 12,
                color: color,
              ),
              const SizedBox(width: 2),
              Text(
                change,
                style: TextStyle(
                  fontSize: 12,
                  color: color,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}