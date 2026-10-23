import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:currensee/screens/alerts_screen.dart';
import 'package:currensee/screens/conversion_screen.dart';
import 'package:currensee/screens/history_screen.dart';
import 'package:currensee/screens/news_screen.dart';
import 'package:currensee/screens/profile_screen.dart';
import 'package:currensee/screens/rates_screen.dart';

final _selectedTabProvider = StateProvider<int>((ref) => 0);

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedTab = ref.watch(_selectedTabProvider);

    final screens = [
      const ConversionScreen(),
      const _RatesHistoryTabScreen(),
      const AlertsScreen(),
      const NewsScreen(),
      const ProfileScreen(),
    ];

    return Scaffold(
      body: IndexedStack(
        index: selectedTab,
        children: screens,
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: selectedTab,
        onDestinationSelected: (index) =>
        ref.read(_selectedTabProvider.notifier).state = index,
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
            icon: Icon(Icons.newspaper_outlined),
            selectedIcon: Icon(Icons.newspaper),
            label: 'News',
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

// ─── Rates + History Tab Screen ───────────────────────────────────────────
class _RatesHistoryTabScreen extends StatelessWidget {
  const _RatesHistoryTabScreen();

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: const Color(0xFFF8F9FA),
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(48),
          child: Container(
            color: Theme.of(context).cardTheme.color ?? Colors.white,
            child: SafeArea(
              child: Container(
                color: Theme.of(context).cardTheme.color ?? Colors.white,
                child: const TabBar(
                  tabs: [
                    Tab(text: 'Exchange Rates'),
                    Tab(text: 'History'),
                  ],
                  labelColor: Color(0xFF1A73E8),
                  unselectedLabelColor: Color(0xFF5F6368),
                  indicatorColor: Color(0xFF1A73E8),
                  labelStyle: TextStyle(fontWeight: FontWeight.w600),
                ),
              ),
            ),
          ),
        ),
        body: const TabBarView(
          children: [
            RatesScreen(),
            HistoryScreen(),
          ],
        ),
      ),
    );
  }
}