
import 'package:flutter/material.dart';

class EmptyAlerts extends StatelessWidget {
  const EmptyAlerts({super.key});

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
                color: const Color(0xFF1A73E8).withOpacity(0.08),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.notifications_none,
                size: 44,
                color: Color(0xFF1A73E8),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'No Alerts Set',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF202124),
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Tap the + button to create a rate alert. We\'ll notify you when your target rate is reached.',
              textAlign: TextAlign.center,
              style: TextStyle(
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