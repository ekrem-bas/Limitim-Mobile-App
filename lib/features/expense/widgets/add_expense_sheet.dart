import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:limitim/features/expense/bloc/session_bloc.dart';

class AddExpenseSheet extends StatefulWidget {
  const AddExpenseSheet({super.key});

  @override
  State<AddExpenseSheet> createState() => _AddExpenseSheetState();
}

class _AddExpenseSheetState extends State<AddExpenseSheet> {
  final String _titleLabelText = "Yeni Harcama";
  final String _titleHintText = "Harcama Başlığı";
  final String _amountLabelText = "Tutar";
  final String _amountCurrencySuffix = "₺";
  final String _addExpenseButtonText = "Harcamayı Ekle";
  final String _cancelButtonText = "Vazgeç";
  final String _titleErrorText = "Başlık gerekli";
  final String _amountErrorText = "Geçerli bir tutar girin";

  final _titleController = TextEditingController();
  final _amountController = TextEditingController();
  String? _titleError;
  String? _amountError;

  void _submit() {
    final title = capitalize(_titleController.text.trim());
    final amountText = _amountController.text.replaceAll(',', '.');
    final amount = double.tryParse(amountText);

    setState(() {
      _titleError = title.isEmpty ? _titleErrorText : null;
      _amountError = (amount == null || amount <= 0) ? _amountErrorText : null;
    });

    if (_titleError == null && _amountError == null) {
      context.read<SessionBloc>().add(
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
          _sheetTitle(),
          const SizedBox(height: 24),
          _expenseTitle(),

          const SizedBox(height: 16),
          _amountTextField(),
          const SizedBox(height: 24),

          // add expense button
          _addExpenseButton(),
          const SizedBox(height: 8),
          // cancel button
          _cancelButton(context),
        ],
      ),
    );
  }

  TextField _expenseTitle() {
    return TextField(
      controller: _titleController,
      decoration: InputDecoration(
        labelText: _titleHintText,
        errorText: _titleError,
        border: const OutlineInputBorder(),
      ),
    );
  }

  Text _sheetTitle() {
    return Text(
      _titleLabelText,
      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
    );
  }

  TextField _amountTextField() {
    return TextField(
      controller: _amountController,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      decoration: InputDecoration(
        labelText: _amountLabelText,
        suffixText: _amountCurrencySuffix,
        errorText: _amountError,
        border: const OutlineInputBorder(),
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

  SizedBox _addExpenseButton() {
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
          _addExpenseButtonText,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}

String capitalize(String text) {
  if (text.isEmpty) return text;
  return toBeginningOfSentenceCase(text.toLowerCase()) ?? text;
}
