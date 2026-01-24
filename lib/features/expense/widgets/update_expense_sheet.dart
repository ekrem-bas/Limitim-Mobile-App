import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:limitim/features/expense/bloc/session_bloc.dart';
import 'package:limitim/features/expense/models/expense.dart';

class UpdateExpenseSheet extends StatefulWidget {
  final Expense expense; // Güncellenecek harcama zorunlu

  const UpdateExpenseSheet({super.key, required this.expense});

  @override
  State<UpdateExpenseSheet> createState() => _UpdateExpenseSheetState();
}

class _UpdateExpenseSheetState extends State<UpdateExpenseSheet> {
  final String _titleLabelText = "Harcamayı Güncelle";
  final String _titleHintText = "Harcama Başlığı";
  final String _amountLabelText = "Tutar";
  final String _amountCurrencySuffix = "₺";
  final String _updateButtonText = "Değişiklikleri Kaydet";
  final String _cancelButtonText = "Vazgeç";
  final String _titleErrorText = "Başlık gerekli";
  final String _amountErrorText = "Geçerli bir tutar girin";

  late final TextEditingController _titleController;
  late final TextEditingController _amountController;
  String? _titleError;
  String? _amountError;

  @override
  void initState() {
    super.initState();
    // set initial values from the expense to be updated
    _titleController = TextEditingController(text: widget.expense.title);
    _amountController = TextEditingController(
      text: widget.expense.amount.toStringAsFixed(2).replaceAll('.', ','),
    );
  }

  void _submit() {
    final title = capitalize(_titleController.text.trim());
    final amountText = _amountController.text.replaceAll(',', '.');
    final amount = double.tryParse(amountText);

    setState(() {
      _titleError = title.isEmpty ? _titleErrorText : null;
      _amountError = (amount == null || amount <= 0) ? _amountErrorText : null;
    });

    if (_titleError == null && _amountError == null) {
      // update the original expense with new values
      final updatedExpense = widget.expense.copyWith(
        title: title,
        amount: amount!,
      );

      // dispatch the update event to the bloc
      context.read<SessionBloc>().add(UpdateExpenseEvent(updatedExpense));

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
          Text(
            _titleLabelText,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 24),

          TextField(
            controller: _titleController,
            decoration: InputDecoration(
              labelText: _titleHintText,
              errorText: _titleError,
              border: const OutlineInputBorder(),
            ),
          ),

          const SizedBox(height: 16),

          TextField(
            controller: _amountController,
            onTap: () {
              _amountController.selection = TextSelection(
                baseOffset: 0,
                extentOffset: _amountController.text.length,
              );
            },
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: InputDecoration(
              labelText: _amountLabelText,
              suffixText: _amountCurrencySuffix,
              errorText: _amountError,
              border: const OutlineInputBorder(),
            ),
          ),

          const SizedBox(height: 24),

          _updateButton(),
          const SizedBox(height: 8),
          _cancelButton(context),
        ],
      ),
    );
  }

  SizedBox _updateButton() {
    return SizedBox(
      width: double.infinity,
      height: 55,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        onPressed: _submit,
        child: Text(
          _updateButtonText,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  SizedBox _cancelButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: TextButton(
        onPressed: () => Navigator.pop(context),
        child: Text(
          _cancelButtonText,
          style: TextStyle(
            color: Theme.of(context).textTheme.bodySmall?.color,
            fontSize: 15,
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _amountController.dispose();
    super.dispose();
  }
}

String capitalize(String text) {
  if (text.isEmpty) return text;
  return toBeginningOfSentenceCase(text.toLowerCase()) ?? text;
}
