
class Currency {
  final String code;
  final String name;
  final String symbol;
  final String flagEmoji;

  const Currency({
    required this.code,
    required this.name,
    required this.symbol,
    required this.flagEmoji,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is Currency && code == other.code;

  @override
  int get hashCode => code.hashCode;
}

// Master list of supported currencies
class CurrencyList {
  static const List<Currency> all = [
    Currency(code: 'USD', name: 'US Dollar', symbol: '\$', flagEmoji: '🇺🇸'),
    Currency(code: 'EUR', name: 'Euro', symbol: '€', flagEmoji: '🇪🇺'),
    Currency(code: 'GBP', name: 'British Pound', symbol: '£', flagEmoji: '🇬🇧'),
    Currency(code: 'NGN', name: 'Nigerian Naira', symbol: '₦', flagEmoji: '🇳🇬'),
    Currency(code: 'JPY', name: 'Japanese Yen', symbol: '¥', flagEmoji: '🇯🇵'),
    Currency(code: 'CAD', name: 'Canadian Dollar', symbol: 'CA\$', flagEmoji: '🇨🇦'),
    Currency(code: 'AUD', name: 'Australian Dollar', symbol: 'A\$', flagEmoji: '🇦🇺'),
    Currency(code: 'CHF', name: 'Swiss Franc', symbol: 'Fr', flagEmoji: '🇨🇭'),
    Currency(code: 'CNY', name: 'Chinese Yuan', symbol: '¥', flagEmoji: '🇨🇳'),
    Currency(code: 'INR', name: 'Indian Rupee', symbol: '₹', flagEmoji: '🇮🇳'),
    Currency(code: 'MXN', name: 'Mexican Peso', symbol: 'MX\$', flagEmoji: '🇲🇽'),
    Currency(code: 'BRL', name: 'Brazilian Real', symbol: 'R\$', flagEmoji: '🇧🇷'),
    Currency(code: 'ZAR', name: 'South African Rand', symbol: 'R', flagEmoji: '🇿🇦'),
    Currency(code: 'GHS', name: 'Ghanaian Cedi', symbol: '₵', flagEmoji: '🇬🇭'),
    Currency(code: 'KES', name: 'Kenyan Shilling', symbol: 'KSh', flagEmoji: '🇰🇪'),
    Currency(code: 'EGP', name: 'Egyptian Pound', symbol: 'E£', flagEmoji: '🇪🇬'),
    Currency(code: 'AED', name: 'UAE Dirham', symbol: 'د.إ', flagEmoji: '🇦🇪'),
    Currency(code: 'SAR', name: 'Saudi Riyal', symbol: '﷼', flagEmoji: '🇸🇦'),
    Currency(code: 'SGD', name: 'Singapore Dollar', symbol: 'S\$', flagEmoji: '🇸🇬'),
    Currency(code: 'HKD', name: 'Hong Kong Dollar', symbol: 'HK\$', flagEmoji: '🇭🇰'),
    Currency(code: 'SEK', name: 'Swedish Krona', symbol: 'kr', flagEmoji: '🇸🇪'),
    Currency(code: 'NOK', name: 'Norwegian Krone', symbol: 'kr', flagEmoji: '🇳🇴'),
    Currency(code: 'DKK', name: 'Danish Krone', symbol: 'kr', flagEmoji: '🇩🇰'),
    Currency(code: 'NZD', name: 'New Zealand Dollar', symbol: 'NZ\$', flagEmoji: '🇳🇿'),
    Currency(code: 'TRY', name: 'Turkish Lira', symbol: '₺', flagEmoji: '🇹🇷'),
    Currency(code: 'RUB', name: 'Russian Ruble', symbol: '₽', flagEmoji: '🇷🇺'),
    Currency(code: 'PKR', name: 'Pakistani Rupee', symbol: '₨', flagEmoji: '🇵🇰'),
    Currency(code: 'BDT', name: 'Bangladeshi Taka', symbol: '৳', flagEmoji: '🇧🇩'),
    Currency(code: 'THB', name: 'Thai Baht', symbol: '฿', flagEmoji: '🇹🇭'),
    Currency(code: 'MYR', name: 'Malaysian Ringgit', symbol: 'RM', flagEmoji: '🇲🇾'),
  ];

  static Currency? findByCode(String code) {
    try {
      return all.firstWhere((c) => c.code == code);
    } catch (_) {
      return null;
    }
  }
}