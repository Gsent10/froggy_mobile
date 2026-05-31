/// Fixed test exchange rates for the five supported currencies.
/// All rates are expressed as: 1 unit of [from] = X units of [to].
/// 
/// Base rates (approximate as of mid-2025 for testing purposes):
///   1 USD = 1,600  NGN
///   1 USD = 0.79   GBP
///   1 USD = 15.50  GHS
///   1 USD = 129.00 KES
///
/// To update for production, replace this class with a live rates API call.
class ExchangeRates {
  ExchangeRates._();

  /// Flat rate table: rates[from][to] = multiplier
  static const Map<String, Map<String, double>> _rates = {
    'USD': {
      'USD': 1.0,
      'NGN': 1600.0,
      'GBP': 0.79,
      'GHS': 15.50,
      'KES': 129.00,
    },
    'NGN': {
      'NGN': 1.0,
      'USD': 0.000625,   // 1 / 1600
      'GBP': 0.000494,   // 0.79 / 1600
      'GHS': 0.009688,   // 15.50 / 1600
      'KES': 0.080625,   // 129.00 / 1600
    },
    'GBP': {
      'GBP': 1.0,
      'USD': 1.2658,     // 1 / 0.79
      'NGN': 2025.32,    // 1600 / 0.79
      'GHS': 19.62,      // 15.50 / 0.79
      'KES': 163.29,     // 129.00 / 0.79
    },
    'GHS': {
      'GHS': 1.0,
      'USD': 0.06452,    // 1 / 15.50
      'NGN': 103.23,     // 1600 / 15.50
      'GBP': 0.05097,    // 0.79 / 15.50
      'KES': 8.3226,     // 129.00 / 15.50
    },
    'KES': {
      'KES': 1.0,
      'USD': 0.007752,   // 1 / 129
      'NGN': 12.403,     // 1600 / 129
      'GBP': 0.006124,   // 0.79 / 129
      'GHS': 0.12016,    // 15.50 / 129
    },
  };

  /// Returns the exchange rate from [fromCode] to [toCode].
  /// Falls back to 1.0 if the pair is not found.
  static double getRate(String fromCode, String toCode) {
    if (fromCode == toCode) return 1.0;
    return _rates[fromCode]?[toCode] ?? 1.0;
  }

  /// Converts [amount] from [fromCode] to [toCode].
  static double convert(double amount, String fromCode, String toCode) {
    return amount * getRate(fromCode, toCode);
  }

  /// Returns a human-readable rate string, e.g. "1 USD = ₦1,600.00"
  static String rateLabel(
    String fromCode,
    String toCode,
    String fromSymbol,
    String toSymbol,
  ) {
    final rate = getRate(fromCode, toCode);
    return '1 $fromCode = $toSymbol${rate.toStringAsFixed(2)} $toCode';
  }
}
