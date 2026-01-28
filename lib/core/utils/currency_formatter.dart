import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

class CurrencyFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    // 1. Eğer alan tamamen boşaltıldıysa
    if (newValue.text.isEmpty) {
      return newValue.copyWith(text: '');
    }

    // 2. Sadece rakam ve virgül girişine izin ver, noktaları (binlikleri) temizle
    String newText = newValue.text.replaceAll('.', '');

    // Birden fazla virgüle veya geçersiz karaktere izin verme
    if (RegExp(r'[^0-9,]').hasMatch(newText) ||
        ','.allMatches(newText).length > 1) {
      return oldValue;
    }

    // 3. Tam ve Ondalık kısımları ayır
    List<String> parts = newText.split(',');
    String integerPart = parts[0];
    String? decimalPart = parts.length > 1 ? parts[1] : null;

    // 4. Tam kısmı binlik ayırıcılarla formatla (intl kullanarak)
    final formatter = NumberFormat('#,###', 'tr_TR');
    String formattedInteger = '';
    if (integerPart.isNotEmpty) {
      // Sayı çok büyükse int parse hatasını önlemek için (Limitim için yeterli)
      formattedInteger = formatter.format(int.parse(integerPart));
    }

    // 5. Nihai stringi oluştur
    String resultText = formattedInteger;
    if (newText.contains(',')) {
      // Kuruş hanesini 2 ile sınırla
      resultText +=
          ',${decimalPart!.substring(0, decimalPart.length > 2 ? 2 : decimalPart.length)}';
    }

    // 6. İmleç konumunu ayarla (Sayı büyüdükçe imlecin sonda kalmasını sağlar)
    return TextEditingValue(
      text: resultText,
      selection: TextSelection.collapsed(offset: resultText.length),
    );
  }
}
