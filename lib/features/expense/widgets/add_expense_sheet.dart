import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:limitim/core/widgets/amount_text_field.dart';
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
  final String _amountHintText = "Örn: 1.250,50";

  final _titleController = TextEditingController();
  String? _titleError;
  String? _amountError;
  double? _currentAmount;

  final FocusNode _amountFocusNode = FocusNode();

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  void _submit() {
    final title = _titleController.text.trim();
    final amount = _currentAmount;

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
      textInputAction: TextInputAction.next,
      onSubmitted: (value) {
        FocusScope.of(context).requestFocus(_amountFocusNode);
      },
    );
  }

  Text _sheetTitle() {
    return Text(
      _titleLabelText,
      style: Theme.of(context).textTheme.displayMedium,
    );
  }

  Widget _amountTextField() {
    return AmountTextField(
      focusNode: _amountFocusNode,
      amountTextLabel: _amountLabelText,
      amountCurrencySuffix: _amountCurrencySuffix,
      amountErrorText: _amountError,
      amountHintText: _amountHintText,
      onAmountChanged: (value) {
        _currentAmount = value;
      },
    );
  }

  SizedBox _cancelButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: TextButton(
        onPressed: () => Navigator.pop(context),
        child: Text(
          _cancelButtonText,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: Theme.of(context).textTheme.bodySmall?.color,
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
          style: TextStyle(
            fontSize: Theme.of(context).textTheme.bodyLarge?.fontSize,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
