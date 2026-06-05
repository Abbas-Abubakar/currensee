
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:currensee/providers/auth_provider.dart';
import 'package:currensee/providers/conversion_provider.dart';
import 'package:currensee/widgets/conversion_result_card.dart';
import 'package:currensee/widgets/currency_picker_sheet.dart';

class ConversionScreen extends ConsumerStatefulWidget {
  const ConversionScreen({super.key});

  @override
  ConsumerState<ConversionScreen> createState() => _ConversionScreenState();
}

class _ConversionScreenState extends ConsumerState<ConversionScreen> {
  final _amountController = TextEditingController(text: '1');
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  void _convert() {
    if (!_formKey.currentState!.validate()) return;
    FocusScope.of(context).unfocus();

    final base = ref.read(baseCurrencyProvider);
    final target = ref.read(targetCurrencyProvider);
    final amount = double.tryParse(_amountController.text) ?? 0;

    ref.read(conversionNotifierProvider.notifier).convert(
      baseCurrency: base.code,
      targetCurrency: target.code,
      amount: amount,
    );
  }

  void _showCurrencyPicker({required bool isBase}) {
    final current = isBase
        ? ref.read(baseCurrencyProvider)
        : ref.read(targetCurrencyProvider);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => CurrencyPickerSheet(
        selected: current,
        onSelected: (currency) {
          if (isBase) {
            ref.read(baseCurrencyProvider.notifier).state = currency;
          } else {
            ref.read(targetCurrencyProvider.notifier).state = currency;
          }
          ref.read(conversionNotifierProvider.notifier).clearResult();
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final base = ref.watch(baseCurrencyProvider);
    final target = ref.watch(targetCurrencyProvider);
    final conversionState = ref.watch(conversionNotifierProvider);
    final user = ref.watch(currentUserProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ─── Header ─────────────────────────────────────────────
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Hello, ${user?.fullName.split(' ').first ?? 'there'} 👋',
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF202124),
                          ),
                        ),
                        const Text(
                          'Convert currencies instantly',
                          style: TextStyle(
                            fontSize: 13,
                            color: Color(0xFF5F6368),
                          ),
                        ),
                      ],
                    ),
                    CircleAvatar(
                      backgroundColor: const Color(0xFF1A73E8),
                      radius: 22,
                      child: Text(
                        (user?.fullName.isNotEmpty == true)
                            ? user!.fullName[0].toUpperCase()
                            : 'U',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 32),

                // ─── Converter Card ──────────────────────────────────────
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.06),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      // ─── Amount Input ──────────────────────────────────
                      TextFormField(
                        controller: _amountController,
                        keyboardType: const TextInputType.numberWithOptions(
                            decimal: true),
                        style: const TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF202124),
                        ),
                        decoration: const InputDecoration(
                          hintText: '0.00',
                          hintStyle: TextStyle(
                            fontSize: 28,
                            color: Colors.grey,
                          ),
                          border: InputBorder.none,
                          enabledBorder: InputBorder.none,
                          focusedBorder: InputBorder.none,
                          filled: false,
                          contentPadding: EdgeInsets.zero,
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter an amount';
                          }
                          final num = double.tryParse(value);
                          if (num == null || num <= 0) {
                            return 'Enter a valid amount';
                          }
                          return null;
                        },
                      ),

                      const SizedBox(height: 20),
                      Divider(color: Colors.grey.shade200),
                      const SizedBox(height: 16),

                      // ─── Base Currency Picker ──────────────────────────
                      _CurrencyRow(
                        label: 'From',
                        code: base.code,
                        name: base.name,
                        flag: base.flagEmoji,
                        onTap: () => _showCurrencyPicker(isBase: true),
                      ),

                      const SizedBox(height: 12),

                      // ─── Swap Button ───────────────────────────────────
                      Center(
                        child: GestureDetector(
                          onTap: () {
                            ref
                                .read(conversionNotifierProvider.notifier)
                                .swapCurrencies();
                          },
                          child: Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: const Color(0xFF1A73E8).withValues(alpha: 0.1),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.swap_vert,
                              color: Color(0xFF1A73E8),
                              size: 24,
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 12),

                      // ─── Target Currency Picker ────────────────────────
                      _CurrencyRow(
                        label: 'To',
                        code: target.code,
                        name: target.name,
                        flag: target.flagEmoji,
                        onTap: () => _showCurrencyPicker(isBase: false),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // ─── Error Message ───────────────────────────────────────
                if (conversionState.errorMessage != null)
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.red.shade50,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.red.shade200),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.error_outline, color: Colors.red.shade700),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            conversionState.errorMessage!,
                            style: TextStyle(color: Colors.red.shade700),
                          ),
                        ),
                      ],
                    ),
                  ),

                const SizedBox(height: 20),

                // ─── Convert Button ──────────────────────────────────────
                ElevatedButton.icon(
                  onPressed: conversionState.isLoading ? null : _convert,
                  icon: conversionState.isLoading
                      ? const SizedBox(
                    height: 18,
                    width: 18,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  )
                      : const Icon(Icons.currency_exchange),
                  label: Text(
                    conversionState.isLoading ? 'Converting...' : 'Convert',
                  ),
                ),

                const SizedBox(height: 24),

                // ─── Result Card ─────────────────────────────────────────
                if (conversionState.result != null)
                  ConversionResultCard(result: conversionState.result!),

                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Currency Row Widget ───────────────────────────────────────────────────
class _CurrencyRow extends StatelessWidget {
  final String label;
  final String code;
  final String name;
  final String flag;
  final VoidCallback onTap;

  const _CurrencyRow({
    required this.label,
    required this.code,
    required this.name,
    required this.flag,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: const Color(0xFFF8F9FA),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Row(
          children: [
            Text(flag, style: const TextStyle(fontSize: 28)),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: const TextStyle(
                      fontSize: 11,
                      color: Color(0xFF5F6368),
                    ),
                  ),
                  Text(
                    code,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF202124),
                    ),
                  ),
                  Text(
                    name,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF5F6368),
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.keyboard_arrow_down,
                color: Color(0xFF1A73E8)),
          ],
        ),
      ),
    );
  }
}