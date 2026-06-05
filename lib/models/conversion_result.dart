
class ConversionResult {
  final String baseCurrency;
  final String targetCurrency;
  final double amount;
  final double convertedAmount;
  final double exchangeRate;
  final DateTime date;

  const ConversionResult({
    required this.baseCurrency,
    required this.targetCurrency,
    required this.amount,
    required this.convertedAmount,
    required this.exchangeRate,
    required this.date,
  });

  Map<String, dynamic> toMap(String uid) {
    return {
      'uid': uid,
      'base_currency': baseCurrency,
      'target_currency': targetCurrency,
      'amount': amount,
      'converted_amount': convertedAmount,
      'exchange_rate': exchangeRate,
      'date': date.toIso8601String(),
    };
  }

  factory ConversionResult.fromMap(Map<String, dynamic> map) {
    return ConversionResult(
      baseCurrency: map['base_currency'] as String,
      targetCurrency: map['target_currency'] as String,
      amount: map['amount'] as double,
      convertedAmount: map['converted_amount'] as double,
      exchangeRate: map['exchange_rate'] as double,
      date: DateTime.parse(map['date'] as String),
    );
  }
}