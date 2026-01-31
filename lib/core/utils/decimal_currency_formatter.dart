import 'package:flutter/services.dart';

class DecimalCurrencyFormatter extends TextInputFormatter {
  final String zws;
  DecimalCurrencyFormatter({required this.zws});

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    // 1. if field is completely cleared return empty (to be handled in onChanged)
    String rawText = newValue.text.replaceAll(zws, "");
    if (rawText.isEmpty) {
      return TextEditingValue(
        text: "${zws}00",
        selection: TextSelection.collapsed(offset: 1),
      );
    }

    // remove zws for processing
    String oldRaw = oldValue.text.replaceAll(zws, "");
    String newRaw = newValue.text.replaceAll(zws, "");

    // 2. placeholder mode (00)
    if (oldRaw == "00") {
      // if more than 2 characters are entered, handle overflow
      if (newRaw.length > 2) {
        // where user is typing
        // if cursor is at the end of the text, user is trying to append to the end of "00"
        // 00| -> 5 pressed -> 005|
        // in this case, there is no placeholder change, but an overflow. REJECT.
        if (newValue.selection.extentOffset == newValue.text.length) {
          return oldValue; // reject overflow (remain "zws00")
        }

        // if cursor is not at the end, user is trying to replace placeholder
        // |00 -> 5 pressed -> 5|00
        // in this case, CHANGE the text.

        // get the new character pressed by user (at the cursor position - 1)
        int newCharIndex = newValue.selection.extentOffset - 1;
        if (newCharIndex >= 0) {
          String newChar = newValue.text[newCharIndex];

          // return new value with zws and new char, move cursor after new char
          return TextEditingValue(
            text: "$zws$newChar",
            selection: const TextSelection.collapsed(offset: 2),
          );
        }
      }
    }
    // 3. normal mode
    // limit to 2 decimal places
    else {
      if (newRaw.length > 2) {
        return oldValue; // Limit aşıldı, engelle
      }
    }

    return newValue;
  }
}
