import 'package:intl/intl.dart';

enum AppCurrency {
  uah('UAH', '₴'),
  usd('USD', '\$');

  final String code;
  final String symbol;
  const AppCurrency(this.code, this.symbol);

  static AppCurrency fromCode(String code) {
    if (code.toUpperCase() == 'USD') return AppCurrency.usd;
    return AppCurrency.uah;
  }
}

class CurrencyFormatter {
  CurrencyFormatter._();

  static final NumberFormat _formatterWithDecimals = NumberFormat('#,##0.00', 'en_US');
  static final NumberFormat _formatterCompact = NumberFormat('#,##0', 'en_US');

  /// Format an amount with currency symbol
  /// e.g. format(1450.50, AppCurrency.uah) -> "1,450.50 ₴"
  /// e.g. format(1450.50, AppCurrency.usd) -> "$1,450.50"
  static String format(
    double amount, {
    AppCurrency currency = AppCurrency.uah,
    bool showDecimals = true,
    bool includePlusSign = false,
  }) {
    final formatted = showDecimals
        ? _formatterWithDecimals.format(amount.abs())
        : _formatterCompact.format(amount.abs());

    final sign = amount < 0 ? '-' : (includePlusSign && amount > 0 ? '+' : '');

    if (currency == AppCurrency.usd) {
      return '$sign\$ $formatted';
    } else {
      return '$sign$formatted ₴';
    }
  }

  /// Converts amount from [from] currency to [to] currency using provided [uahToUsdRate]
  /// rate = 1 USD in UAH (e.g. 41.50)
  static double convert({
    required double amount,
    required AppCurrency from,
    required AppCurrency to,
    required double uahToUsdRate,
  }) {
    if (from == to) return amount;
    if (uahToUsdRate <= 0) return amount;

    if (from == AppCurrency.uah && to == AppCurrency.usd) {
      return amount / uahToUsdRate;
    } else if (from == AppCurrency.usd && to == AppCurrency.uah) {
      return amount * uahToUsdRate;
    }
    return amount;
  }
}
