import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

class IntegerCurrencyFormatter extends TextInputFormatter {
  final double maxLimit;
  final VoidCallback? onLimitExceeded; // callback for limit exceeded

  IntegerCurrencyFormatter({
    this.maxLimit = 1000000000000,
    this.onLimitExceeded,
  });

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    if (oldValue.text == "0" && newValue.text.isNotEmpty) {
      String newChar = newValue.text[newValue.selection.extentOffset - 1];
      return TextEditingValue(
        text: newChar,
        selection: TextSelection.collapsed(offset: 1),
      );
    }

    // 1. if field is completely cleared return empty (to be handled in onChanged)
    if (newValue.text.isEmpty) {
      return TextEditingValue(
        text: "0",
        selection: const TextSelection.collapsed(offset: 0),
      );
    }

    // 2. allow only digits and comma, remove dots (thousands)
    String newText = newValue.text.replaceAll('.', '');

    // do not allow multiple commas or invalid characters
    if (RegExp(r'[^0-9,]').hasMatch(newText) ||
        ','.allMatches(newText).length > 1) {
      return oldValue;
    }

    // 3. split integer and decimal parts
    List<String> parts = newText.split(',');
    String integerPart = parts[0];
    String? decimalPart = parts.length > 1 ? parts[1] : null;

    // 4. format integer part with thousand separators (using intl)
    final formatter = NumberFormat('#,###', 'tr_TR');
    String formattedInteger = '';
    if (integerPart.isNotEmpty) {
      int intValue = int.parse(integerPart);
      if (intValue > maxLimit) {
        return oldValue;
      }
      formattedInteger = formatter.format(intValue);
    }

    // 5. combine integer and decimal parts
    String resultText = formattedInteger;
    if (newText.contains(',')) {
      // if there is a decimal part, add it (limit to 2 digits)
      resultText +=
          ',${decimalPart!.substring(0, decimalPart.length > 2 ? 2 : decimalPart.length)}';
    }

    // 6. adjust cursor position (keeps cursor at the end as number grows)
    return TextEditingValue(
      text: resultText,
      selection: TextSelection.collapsed(offset: resultText.length),
    );
  }
}
