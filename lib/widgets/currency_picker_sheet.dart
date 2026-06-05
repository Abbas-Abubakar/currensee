// lib/features/conversion/view/widgets/currency_picker_sheet.dart

import 'package:flutter/material.dart';
import 'package:currensee/models/currency.dart';

class CurrencyPickerSheet extends StatefulWidget {
  final Currency selected;
  final Function(Currency) onSelected;

  const CurrencyPickerSheet({
    super.key,
    required this.selected,
    required this.onSelected,
  });

  @override
  State<CurrencyPickerSheet> createState() => _CurrencyPickerSheetState();
}

class _CurrencyPickerSheetState extends State<CurrencyPickerSheet> {
  final _searchController = TextEditingController();
  List<Currency> _filtered = CurrencyList.all;

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
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          // ─── Handle ────────────────────────────────────────────────────
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

          // ─── Title ─────────────────────────────────────────────────────
          const Text(
            'Select Currency',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF202124),
            ),
          ),

          const SizedBox(height: 16),

          // ─── Search ────────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: TextField(
              controller: _searchController,
              onChanged: _onSearch,
              decoration: InputDecoration(
                hintText: 'Search currency...',
                prefixIcon: const Icon(Icons.search, color: Colors.grey),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                  icon: const Icon(Icons.clear, color: Colors.grey),
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

          // ─── Currency List ─────────────────────────────────────────────
          Expanded(
            child: ListView.builder(
              itemCount: _filtered.length,
              itemBuilder: (context, index) {
                final currency = _filtered[index];
                final isSelected = currency.code == widget.selected.code;

                return ListTile(
                  leading: Text(
                    currency.flagEmoji,
                    style: const TextStyle(fontSize: 28),
                  ),
                  title: Text(
                    currency.code,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 15,
                    ),
                  ),
                  subtitle: Text(
                    currency.name,
                    style: TextStyle(
                      color: Colors.grey.shade600,
                      fontSize: 13,
                    ),
                  ),
                  trailing: isSelected
                      ? const Icon(Icons.check_circle,
                      color: Color(0xFF1A73E8))
                      : Text(
                    currency.symbol,
                    style: TextStyle(
                      color: Colors.grey.shade500,
                      fontSize: 16,
                    ),
                  ),
                  onTap: () {
                    widget.onSelected(currency);
                    Navigator.pop(context);
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