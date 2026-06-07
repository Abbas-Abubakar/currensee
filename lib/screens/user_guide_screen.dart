import 'package:flutter/material.dart';
import 'package:currensee/widgets/guide_step_card.dart';

class UserGuideScreen extends StatelessWidget {
  const UserGuideScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(title: const Text('User Guide')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ─── Getting Started ───────────────────────────────────────
            _SectionHeader(title: '🚀 Getting Started'),
            const SizedBox(height: 12),
            const GuideStepCard(
              step: 1,
              title: 'Create an Account',
              description:
              'Download CurrenSee and sign up with your email and password or continue with Google. Your data is securely stored and synced across devices.',
              icon: Icons.person_add_outlined,
            ),
            const GuideStepCard(
              step: 2,
              title: 'Set Your Default Currency',
              description:
              'Go to Profile → Preferences → Default Currency and select your home currency. This will be pre-selected every time you open the app.',
              icon: Icons.tune_outlined,
            ),
            const GuideStepCard(
              step: 3,
              title: 'Convert Your First Currency',
              description:
              'Tap the Convert tab, select your From and To currencies, enter an amount and tap Convert. The result appears instantly with the live rate.',
              icon: Icons.currency_exchange,
            ),

            const SizedBox(height: 24),

            // ─── Using Rates ───────────────────────────────────────────
            _SectionHeader(title: '📊 Exchange Rates'),
            const SizedBox(height: 12),
            const GuideStepCard(
              step: 1,
              title: 'Browse Live Rates',
              description:
              'The Rates tab shows live exchange rates for all supported currencies against your base currency. Use the search bar or sort options to find what you need.',
              icon: Icons.bar_chart,
            ),
            const GuideStepCard(
              step: 2,
              title: 'View Currency Details',
              description:
              'Tap any currency in the list to see detailed information including the current rate, inverse rate, 30-day trend chart, and 30-day high and low.',
              icon: Icons.info_outline,
            ),
            const GuideStepCard(
              step: 3,
              title: 'View Conversion History',
              description:
              'Switch to the History tab under Rates to see all your past conversions. Filter by currency pair or swipe left on any entry to delete it.',
              icon: Icons.history,
            ),

            const SizedBox(height: 24),

            // ─── Rate Alerts ───────────────────────────────────────────
            _SectionHeader(title: '🔔 Rate Alerts'),
            const SizedBox(height: 12),
            const GuideStepCard(
              step: 1,
              title: 'Create an Alert',
              description:
              'Go to the Alerts tab and tap New Alert. Choose your currency pair, set whether to alert above or below a rate, and enter your target rate.',
              icon: Icons.add_alert_outlined,
            ),
            const GuideStepCard(
              step: 2,
              title: 'Check Your Alerts',
              description:
              'Tap the refresh icon on the Alerts screen to check all active alerts against live rates. You will receive a notification if any threshold is met.',
              icon: Icons.refresh,
            ),
            const GuideStepCard(
              step: 3,
              title: 'Manage Alerts',
              description:
              'Toggle alerts on or off using the switch on each alert card. Swipe left to delete an alert. Triggered alerts are automatically deactivated.',
              icon: Icons.toggle_on_outlined,
            ),

            const SizedBox(height: 24),

            // ─── News ──────────────────────────────────────────────────
            _SectionHeader(title: '📰 Market News'),
            const SizedBox(height: 12),
            const GuideStepCard(
              step: 1,
              title: 'Browse Currency News',
              description:
              'The News tab shows the latest currency and forex articles. Filter by All, Forex, or Business using the category chips at the top.',
              icon: Icons.newspaper_outlined,
            ),
            const GuideStepCard(
              step: 2,
              title: 'Read Full Articles',
              description:
              'Tap any news card to open the full article in the built-in browser. Pull down to refresh the news feed at any time.',
              icon: Icons.open_in_browser_outlined,
            ),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 17,
        fontWeight: FontWeight.bold,
        color: Color(0xFF202124),
      ),
    );
  }
}