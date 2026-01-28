import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

class CurrencyFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    // clear text if empty
    if (newValue.text.isEmpty) return newValue.copyWith(text: '');

    // remove existing dots
    String text = newValue.text.replaceAll('.', '');

    // Only allow digits and a single comma (max 2 decimal places)
    final regExp = RegExp(r'^\d*,?\d{0,2}$');
    if (!regExp.hasMatch(text)) return oldValue;

    // Split integer and decimal parts
    List<String> parts = text.split(',');
    String integerPart = parts[0];
    String decimalPart = parts.length > 1 ? parts[1] : "";

    // Format integer part with thousand separators
    final formatter = NumberFormat('#,###', 'tr_TR');
    String formattedInteger = '';

    if (integerPart.isNotEmpty) {
      formattedInteger = formatter.format(int.parse(integerPart));
    } else if (text.startsWith(',')) {
      // Handle case where user starts with a comma
      formattedInteger = '0';
    }

    // Create final text (If comma pressed, add comma and decimal part if any)
    String finalString = formattedInteger;
    if (text.contains(',')) {
      finalString += ',$decimalPart';
    }

    return newValue.copyWith(
      text: finalString,
      selection: TextSelection.collapsed(offset: finalString.length),
    );
  }
}
