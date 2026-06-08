
import 'package:flutter/material.dart';
import 'package:currensee/screens/contact_screen.dart';
import 'package:currensee/screens/faq_screen.dart';
import 'package:currensee/screens/user_guide_screen.dart';
import 'package:currensee/widgets/support_option_card.dart';

class SupportScreen extends StatelessWidget {
  const SupportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(title: const Text('Help & Support')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ─── Hero ──────────────────────────────────────────────────
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF1A73E8), Color(0xFF0D47A1)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.support_agent,
                      color: Colors.white, size: 40),
                  const SizedBox(height: 12),
                  const Text(
                    'How can we help you?',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Find answers, guides, or reach out to our team.',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.85),
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 28),

            // ─── Support Options ───────────────────────────────────────
            Text(
              'SUPPORT OPTIONS',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                letterSpacing: 1.2,
              ),
            ),
            const SizedBox(height: 12),

            SupportOptionCard(
              icon: Icons.quiz_outlined,
              iconColor: const Color(0xFF1A73E8),
              title: 'Frequently Asked Questions',
              subtitle: 'Quick answers to common questions',
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const FaqScreen()),
              ),
            ),
            const SizedBox(height: 10),
            SupportOptionCard(
              icon: Icons.menu_book_outlined,
              iconColor: const Color(0xFF34A853),
              title: 'User Guide',
              subtitle: 'Step-by-step guide to using CurrenSee',
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (_) => const UserGuideScreen()),
              ),
            ),
            const SizedBox(height: 10),
            SupportOptionCard(
              icon: Icons.email_outlined,
              iconColor: const Color(0xFFFFA000),
              title: 'Contact Support',
              subtitle: 'Send us a message, we respond in 24hrs',
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (_) => const ContactScreen()),
              ),
            ),

            const SizedBox(height: 28),

            // ─── About Section ─────────────────────────────────────────
            const Text(
              'ABOUT',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: Color(0xFF5F6368),
                letterSpacing: 1.2,
              ),
            ),
            const SizedBox(height: 12),

            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Theme.of(context).cardTheme.color ?? Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Container(
                    width: 100,
                    height: 100,
                    child: const Image(image: AssetImage('images/app_icon.png'), width: 100, height: 100,),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'CurrenSee',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Version 1.0.0',
                    style: TextStyle(
                      fontSize: 13,
                      color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'CurrenSee is a smart currency conversion app developed by ABC Finance Ltd. Built to help individuals, travelers, and businesses manage currency conversions with ease.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 13,
                      color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                      height: 1.6,
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Divider(),
                  const SizedBox(height: 8),
                  Text(
                    'Commissioned & owned by ABC Finance Ltd.',
                    style: TextStyle(fontSize: 11, color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6)),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '© 2026 CurrenSee. All rights reserved.',
                    style: TextStyle(fontSize: 11, color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6)),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}