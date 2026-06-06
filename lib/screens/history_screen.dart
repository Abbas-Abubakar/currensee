
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:currensee/providers/history_provider.dart';
import 'package:currensee/widgets/empty_history.dart';
import 'package:currensee/widgets/history_tile.dart';

class HistoryScreen extends ConsumerWidget {
  const HistoryScreen({super.key});

  void _showClearConfirmDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape:
        RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Clear All History'),
        content: const Text(
          'This will permanently delete all your conversion history. This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              ref.read(historyNotifierProvider.notifier).clearAll();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              minimumSize: const Size(80, 40),
            ),
            child: const Text('Clear All'),
          ),
        ],
      ),
    );
  }

  void _showFilterSheet(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const _FilterSheet(),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final historyAsync = ref.watch(historyProvider);
    final baseFilter = ref.watch(historyBaseFilterProvider);
    final targetFilter = ref.watch(historyTargetFilterProvider);
    final isFiltered = baseFilter.isNotEmpty || targetFilter.isNotEmpty;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ─── Header ──────────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'History',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF202124),
                        ),
                      ),
                      Text(
                        'Your past conversions',
                        style: TextStyle(
                          fontSize: 13,
                          color: Color(0xFF5F6368),
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      // Filter button
                      Stack(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.filter_list),
                            onPressed: () => _showFilterSheet(context, ref),
                            tooltip: 'Filter',
                          ),
                          if (isFiltered)
                            Positioned(
                              right: 8,
                              top: 8,
                              child: Container(
                                width: 8,
                                height: 8,
                                decoration: const BoxDecoration(
                                  color: Color(0xFF1A73E8),
                                  shape: BoxShape.circle,
                                ),
                              ),
                            ),
                        ],
                      ),
                      // Clear all button
                      IconButton(
                        icon: const Icon(Icons.delete_sweep_outlined),
                        onPressed: () =>
                            _showClearConfirmDialog(context, ref),
                        tooltip: 'Clear all',
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // ─── Active Filters Badge ─────────────────────────────────────
            if (isFiltered)
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
                child: Wrap(
                  spacing: 8,
                  children: [
                    if (baseFilter.isNotEmpty)
                      _FilterChipBadge(
                        label: 'From: $baseFilter',
                        onRemove: () => ref
                            .read(historyBaseFilterProvider.notifier)
                            .state = '',
                      ),
                    if (targetFilter.isNotEmpty)
                      _FilterChipBadge(
                        label: 'To: $targetFilter',
                        onRemove: () => ref
                            .read(historyTargetFilterProvider.notifier)
                            .state = '',
                      ),
                  ],
                ),
              ),

            const SizedBox(height: 12),

            // ─── History List ─────────────────────────────────────────────
            Expanded(
              child: historyAsync.when(
                loading: () =>
                const Center(child: CircularProgressIndicator()),
                error: (e, _) => Center(
                  child: Text(
                    'Error loading history.\n${e.toString()}',
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.grey),
                  ),
                ),
                data: (history) {
                  if (history.isEmpty) {
                    return EmptyHistory(isFiltered: isFiltered);
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
                    itemCount: history.length,
                    itemBuilder: (context, index) {
                      final entry = history[index];
                      return HistoryTile(
                        result: entry,
                        onDelete: () {
                          if (entry.id != null) {
                            ref
                                .read(historyNotifierProvider.notifier)
                                .deleteEntry(entry.id!);
                          }
                        },
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Filter Chip Badge ────────────────────────────────────────────────────
class _FilterChipBadge extends StatelessWidget {
  final String label;
  final VoidCallback onRemove;

  const _FilterChipBadge({required this.label, required this.onRemove});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: const Color(0xFF1A73E8).withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFF1A73E8).withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              color: Color(0xFF1A73E8),
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(width: 4),
          GestureDetector(
            onTap: onRemove,
            child: const Icon(Icons.close,
                size: 14, color: Color(0xFF1A73E8)),
          ),
        ],
      ),
    );
  }
}

// ─── Filter Bottom Sheet ──────────────────────────────────────────────────
class _FilterSheet extends ConsumerWidget {
  const _FilterSheet();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final baseCurrenciesAsync = ref.watch(usedBaseCurrenciesProvider);
    final targetCurrenciesAsync = ref.watch(usedTargetCurrenciesProvider);
    final baseFilter = ref.watch(historyBaseFilterProvider);
    final targetFilter = ref.watch(historyTargetFilterProvider);

    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Handle
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Filter History',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF202124),
            ),
          ),
          const SizedBox(height: 20),

          // From currency filter
          const Text(
            'From Currency',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: Color(0xFF5F6368),
            ),
          ),
          const SizedBox(height: 8),
          baseCurrenciesAsync.when(
            loading: () => const LinearProgressIndicator(),
            error: (_, __) => const Text('Could not load filters'),
            data: (currencies) => currencies.isEmpty
                ? const Text('No data yet',
                style: TextStyle(color: Colors.grey))
                : Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _ChoiceChip(
                  label: 'All',
                  selected: baseFilter.isEmpty,
                  onSelected: () => ref
                      .read(historyBaseFilterProvider.notifier)
                      .state = '',
                ),
                ...currencies.map(
                      (c) => _ChoiceChip(
                    label: c,
                    selected: baseFilter == c,
                    onSelected: () => ref
                        .read(historyBaseFilterProvider.notifier)
                        .state = c,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // To currency filter
          const Text(
            'To Currency',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: Color(0xFF5F6368),
            ),
          ),
          const SizedBox(height: 8),
          targetCurrenciesAsync.when(
            loading: () => const LinearProgressIndicator(),
            error: (_, __) => const Text('Could not load filters'),
            data: (currencies) => currencies.isEmpty
                ? const Text('No data yet',
                style: TextStyle(color: Colors.grey))
                : Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _ChoiceChip(
                  label: 'All',
                  selected: targetFilter.isEmpty,
                  onSelected: () => ref
                      .read(historyTargetFilterProvider.notifier)
                      .state = '',
                ),
                ...currencies.map(
                      (c) => _ChoiceChip(
                    label: c,
                    selected: targetFilter == c,
                    onSelected: () => ref
                        .read(historyTargetFilterProvider.notifier)
                        .state = c,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Apply button
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Apply Filters'),
          ),
        ],
      ),
    );
  }
}

class _ChoiceChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onSelected;

  const _ChoiceChip({
    required this.label,
    required this.selected,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onSelected,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          color: selected
              ? const Color(0xFF1A73E8)
              : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selected
                ? const Color(0xFF1A73E8)
                : Colors.grey.shade300,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight:
            selected ? FontWeight.w600 : FontWeight.normal,
            color: selected ? Colors.white : const Color(0xFF202124),
          ),
        ),
      ),
    );
  }
}