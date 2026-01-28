import 'package:intl/intl.dart';

class CurrencyHelper {
  static String format(double value) {
    // show currency with 2 decimal places
    return NumberFormat.currency(
      locale: 'tr_TR',
      symbol: '₺',
      decimalDigits: 2,
    ).format(value);
  }
}
