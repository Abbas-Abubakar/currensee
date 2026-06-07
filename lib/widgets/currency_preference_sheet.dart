import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:currensee/providers/profile_provider.dart';
import 'package:currensee/models/currency.dart';

class CurrencyPreferenceSheet extends ConsumerStatefulWidget {
  final String currentDefault;

  const CurrencyPreferenceSheet({
    super.key,
    required this.currentDefault,
  });

  @override
  ConsumerState<CurrencyPreferenceSheet> createState() =>
      _CurrencyPreferenceSheetState();
}

class _CurrencyPreferenceSheetState
    extends ConsumerState<CurrencyPreferenceSheet> {
  final _searchController = TextEditingController();
  List<Currency> _filtered = CurrencyList.all;
  late String _selected;

  @override
  void initState() {
    super.initState();
    _selected = widget.currentDefault;
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSearch(String query) {
    setState(() {
      _filtered = CurrencyList.all
          .where((c) =>
      c.code.toLowerCase().contains(query.toLowerCase()) ||
          c.name.toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.75,
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color ?? Colors.white,
        borderRadius:
        const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          const SizedBox(height: 12),
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Default Currency',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: TextField(
              controller: _searchController,
              onChanged: _onSearch,
              decoration: InputDecoration(
                hintText: 'Search currency...',
                prefixIcon:
                const Icon(Icons.search, color: Colors.grey),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                  icon: const Icon(Icons.clear,
                      color: Colors.grey),
                  onPressed: () {
                    _searchController.clear();
                    _onSearch('');
                  },
                )
                    : null,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: ListView.builder(
              itemCount: _filtered.length,
              itemBuilder: (context, index) {
                final currency = _filtered[index];
                final isSelected = currency.code == _selected;

                return ListTile(
                  leading: Text(
                    currency.flagEmoji,
                    style: const TextStyle(fontSize: 26),
                  ),
                  title: Text(
                    currency.code,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  subtitle: Text(currency.name),
                  trailing: isSelected
                      ? const Icon(Icons.check_circle,
                      color: Color(0xFF1A73E8))
                      : null,
                  onTap: () async {
                    setState(() => _selected = currency.code);
                    await ref
                        .read(profileNotifierProvider.notifier)
                        .saveDefaultCurrency(currency.code);
                    if (context.mounted) {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                              '${currency.code} set as default currency'),
                          backgroundColor: Colors.green.shade700,
                          behavior: SnackBarBehavior.floating,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10)),
                        ),
                      );
                    }
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}