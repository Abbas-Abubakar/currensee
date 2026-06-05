// lib/features/conversion/view/home_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:currensee/providers/auth_provider.dart';
import 'package:currensee/screens/conversion_screen.dart';

// Placeholder screens — we'll replace these as we build each feature
class _PlaceholderScreen extends StatelessWidget {
  final String title;
  const _PlaceholderScreen({required this.title});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text(
          title,
          style: const TextStyle(fontSize: 18, color: Colors.grey),
        ),
      ),
    );
  }
}

final _selectedTabProvider = StateProvider<int>((ref) => 0);

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedTab = ref.watch(_selectedTabProvider);

    final screens = [
      const ConversionScreen(),
      const _PlaceholderScreen(title: 'Rates & History'),
      const _PlaceholderScreen(title: 'Alerts'),
      const _PlaceholderScreen(title: 'Profile & Settings'),
    ];

    return Scaffold(
      body: IndexedStack(
        index: selectedTab,
        children: screens,
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: selectedTab,
        onDestinationSelected: (index) {
          // Sign out on long press of profile tab (dev shortcut)
          ref.read(_selectedTabProvider.notifier).state = index;
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.currency_exchange_outlined),
            selectedIcon: Icon(Icons.currency_exchange),
            label: 'Convert',
          ),
          NavigationDestination(
            icon: Icon(Icons.bar_chart_outlined),
            selectedIcon: Icon(Icons.bar_chart),
            label: 'Rates',
          ),
          NavigationDestination(
            icon: Icon(Icons.notifications_outlined),
            selectedIcon: Icon(Icons.notifications),
            label: 'Alerts',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}