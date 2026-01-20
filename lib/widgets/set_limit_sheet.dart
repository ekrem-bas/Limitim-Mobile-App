import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:limitim/bloc/session_bloc/active_session_bloc.dart';

class SetLimitSheet extends StatefulWidget {
  const SetLimitSheet({super.key});

  @override
  State<SetLimitSheet> createState() => _SetLimitSheetState();
}

class _SetLimitSheetState extends State<SetLimitSheet> {
  final _limitController = TextEditingController();
  String? _limitError;

  void _submit() {
    final limitText = _limitController.text.replaceAll(',', '.');
    final limit = double.tryParse(limitText);

    if (limit == null || limit <= 0) {
      setState(() {
        _limitError = "Lütfen geçerli bir limit girin";
      });
    } else {
      context.read<ActiveSessionBloc>().add(StartNewSession(limit));
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      // Klavyenin sheet'i yukarı itmesi için viewInsets kullanıyoruz
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
        left: 24,
        right: 24,
        top: 24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            "Yeni Limit Belirle",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            "Bu ay için harcayabileceğiniz toplam miktarı giriniz.",
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Theme.of(
                context,
              ).colorScheme.onSurface.withValues(alpha: 0.6),
            ),
          ),
          const SizedBox(height: 24),

          TextField(
            controller: _limitController,
            autofocus: true, // Sheet açılınca klavye otomatik açılsın
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            inputFormatters: [
              // Virgülü anında noktaya çeviriyoruz
              TextInputFormatter.withFunction((oldValue, newValue) {
                return newValue.copyWith(
                  text: newValue.text.replaceAll(',', '.'),
                );
              }),
            ],
            decoration: InputDecoration(
              labelText: "Aylık Limit",
              hintText: "Örn: 5000",
              suffixText: "₺",
              errorText: _limitError,
              border: const OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 32),

          // BAŞLAT BUTONU (Siyah)
          SizedBox(
            width: double.infinity,
            height: 55,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.primary,
                foregroundColor: Theme.of(context).colorScheme.onPrimary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: _submit,
              child: const Text(
                "Bütçeyi Başlat",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ),

          const SizedBox(height: 8),

          // VAZGEÇ BUTONU (Soluk)
          SizedBox(
            width: double.infinity,
            child: TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                "Vazgeç",
                style: TextStyle(
                  color: Theme.of(context).textTheme.bodySmall?.color,
                  fontSize: 15,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
