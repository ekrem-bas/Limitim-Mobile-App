import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:limitim/bloc/session_bloc/active_session_bloc.dart';

class AddExpenseSheet extends StatefulWidget {
  const AddExpenseSheet({super.key});

  @override
  State<AddExpenseSheet> createState() => _AddExpenseSheetState();
}

class _AddExpenseSheetState extends State<AddExpenseSheet> {
  final _titleController = TextEditingController();
  final _amountController = TextEditingController();
  String? _titleError;
  String? _amountError;

  void _submit() {
    final title = _titleController.text.trim();
    final amountText = _amountController.text.replaceAll(',', '.');
    final amount = double.tryParse(amountText);

    setState(() {
      _titleError = title.isEmpty ? "Başlık gerekli" : null;
      _amountError = (amount == null || amount <= 0)
          ? "Geçerli bir tutar girin"
          : null;
    });

    if (_titleError == null && _amountError == null) {
      context.read<ActiveSessionBloc>().add(
        AddExpenseEvent(title: title, amount: amount!),
      );
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
        left: 20,
        right: 20,
        top: 20,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            "Yeni Harcama",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 24),
          TextField(
            controller: _titleController,
            decoration: InputDecoration(
              labelText: "Harcama Başlığı",
              errorText: _titleError,
              border: const OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _amountController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: InputDecoration(
              labelText: "Tutar",
              suffixText: "₺",
              errorText: _amountError,
              border: const OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 24),

          // ANA EKLE BUTONU (Siyah)
          SizedBox(
            width: double.infinity,
            height: 55,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: _submit,
              child: const Text(
                "Harcamayı Ekle",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ),

          const SizedBox(height: 8),

          // VAZGEÇ BUTONU (Soluk/Subtle)
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
