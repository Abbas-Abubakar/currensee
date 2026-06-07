
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:currensee/providers/alerts_provider.dart';
import 'package:currensee/widgets/currency_picker_sheet.dart';
import 'package:currensee/models/currency.dart';

class AddAlertSheet extends ConsumerStatefulWidget {
  const AddAlertSheet({super.key});

  @override
  ConsumerState<AddAlertSheet> createState() => _AddAlertSheetState();
}

class _AddAlertSheetState extends ConsumerState<AddAlertSheet> {
  Currency _baseCurrency = CurrencyList.findByCode('USD')!;
  Currency _targetCurrency = CurrencyList.findByCode('NGN')!;
  bool _isAbove = true;
  final _rateController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _rateController.dispose();
    super.dispose();
  }

  void _pickCurrency({required bool isBase}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => CurrencyPickerSheet(
        selected: isBase ? _baseCurrency : _targetCurrency,
        onSelected: (currency) {
          setState(() {
            if (isBase) {
              _baseCurrency = currency;
            } else {
              _targetCurrency = currency;
            }
          });
        },
      ),
    );
  }

  Future<void> _createAlert() async {
    if (!_formKey.currentState!.validate()) return;

    final rate = double.tryParse(_rateController.text);
    if (rate == null || rate <= 0) return;

    final success = await ref.read(alertsNotifierProvider.notifier).createAlert(
      baseCurrency: _baseCurrency.code,
      targetCurrency: _targetCurrency.code,
      targetRate: rate,
      isAbove: _isAbove,
    );

    if (success && mounted) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Alert created successfully!'),
          backgroundColor: Colors.green.shade700,
          behavior: SnackBarBehavior.floating,
          shape:
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final alertState = ref.watch(alertsNotifierProvider);
    final isLoading = alertState is AsyncLoading;

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Container(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ─── Handle ────────────────────────────────────────────────
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
                'Create Rate Alert',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF202124),
                ),
              ),

              const SizedBox(height: 20),

              // ─── Currency Pair ──────────────────────────────────────────
              Row(
                children: [
                  Expanded(
                    child: _CurrencySelector(
                      label: 'From',
                      currency: _baseCurrency,
                      onTap: () => _pickCurrency(isBase: true),
                    ),
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 8),
                    child: Icon(Icons.arrow_forward,
                        color: Colors.grey),
                  ),
                  Expanded(
                    child: _CurrencySelector(
                      label: 'To',
                      currency: _targetCurrency,
                      onTap: () => _pickCurrency(isBase: false),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              // ─── Direction Toggle ────────────────────────────────────────
              const Text(
                'Alert me when rate goes',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF5F6368),
                ),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: _DirectionButton(
                      label: 'Above ↑',
                      selected: _isAbove,
                      color: const Color(0xFF34A853),
                      onTap: () => setState(() => _isAbove = true),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _DirectionButton(
                      label: 'Below ↓',
                      selected: !_isAbove,
                      color: const Color(0xFFEA4335),
                      onTap: () => setState(() => _isAbove = false),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              // ─── Target Rate Input ───────────────────────────────────────
              const Text(
                'Target Rate',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF5F6368),
                ),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _rateController,
                keyboardType:
                const TextInputType.numberWithOptions(decimal: true),
                decoration: InputDecoration(
                  hintText:
                  'e.g. 1600 (1 ${_baseCurrency.code} = ? ${_targetCurrency.code})',
                  prefixIcon: const Icon(Icons.price_change_outlined),
                ),
                validator: (val) {
                  if (val == null || val.isEmpty) {
                    return 'Please enter a target rate';
                  }
                  final parsed = double.tryParse(val);
                  if (parsed == null || parsed <= 0) {
                    return 'Enter a valid rate greater than 0';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 24),

              // ─── Create Button ───────────────────────────────────────────
              ElevatedButton.icon(
                onPressed: isLoading ? null : _createAlert,
                icon: isLoading
                    ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2,
                  ),
                )
                    : const Icon(Icons.add_alert),
                label:
                Text(isLoading ? 'Creating...' : 'Create Alert'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Currency Selector Button ─────────────────────────────────────────────
class _CurrencySelector extends StatelessWidget {
  final String label;
  final Currency currency;
  final VoidCallback onTap;

  const _CurrencySelector({
    required this.label,
    required this.currency,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: const Color(0xFFF8F9FA),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label,
                style: const TextStyle(
                    fontSize: 11, color: Color(0xFF5F6368))),
            const SizedBox(height: 4),
            Row(
              children: [
                Text(currency.flagEmoji,
                    style: const TextStyle(fontSize: 18)),
                const SizedBox(width: 6),
                Text(
                  currency.code,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                const Spacer(),
                const Icon(Icons.keyboard_arrow_down,
                    size: 16, color: Colors.grey),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Direction Button ─────────────────────────────────────────────────────
class _DirectionButton extends StatelessWidget {
  final String label;
  final bool selected;
  final Color color;
  final VoidCallback onTap;

  const _DirectionButton({
    required this.label,
    required this.selected,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: selected ? color.withOpacity(0.1) : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: selected ? color : Colors.grey.shade300,
            width: selected ? 2 : 1,
          ),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              color: selected ? color : Colors.grey,
              fontWeight:
              selected ? FontWeight.bold : FontWeight.normal,
              fontSize: 14,
            ),
          ),
        ),
      ),
    );
  }
}