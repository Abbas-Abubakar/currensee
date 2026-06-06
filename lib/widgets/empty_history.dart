import 'package:flutter/material.dart';

class EmptyHistory extends StatelessWidget {
  final bool isFiltered;

  const EmptyHistory({super.key, this.isFiltered = false});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 90,
              height: 90,
              decoration: BoxDecoration(
                color: const Color(0xFF1A73E8).withValues(alpha: 0.08),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.history,
                size: 44,
                color: Color(0xFF1A73E8),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              isFiltered ? 'No Results Found' : 'No Conversions Yet',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF202124),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              isFiltered
                  ? 'Try changing or clearing your filters.'
                  : 'Your conversion history will appear here after you convert currencies.',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 13,
                color: Color(0xFF5F6368),
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}