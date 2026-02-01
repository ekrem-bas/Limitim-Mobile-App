import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:limitim/core/widgets/amount_text_field.dart';
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
  final ScrollController _titleScrollController = ScrollController();
  final FocusNode _amountFocusNode = FocusNode();
  double? _currentAmount;
  String? _titleError;
  String? _amountError;

  @override
  void initState() {
    super.initState();
    // set initial values from the expense to be updated
    _titleController = TextEditingController(text: widget.expense.title);
    _currentAmount = widget.expense.amount;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_titleScrollController.hasClients) {
        // maxScrollExtent: Metnin bittiği en son piksel noktası
        _titleScrollController.jumpTo(
          _titleScrollController.position.maxScrollExtent,
        );
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
    _titleController.dispose();
    _titleScrollController.dispose();
  }

  void _submit() {
    final title = _titleController.text.trim();
    final amount = _currentAmount;

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
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            _titleLabelText,
            style: Theme.of(context).textTheme.displayMedium,
          ),
          const SizedBox(height: 24),

          TextField(
            controller: _titleController,
            scrollController: _titleScrollController,
            minLines: 1,
            maxLines: 3,
            decoration: InputDecoration(
              labelText: _titleHintText,
              errorText: _titleError,
              border: const OutlineInputBorder(),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 16,
              ),
            ),
            textInputAction: TextInputAction.next,
            onSubmitted: (value) {
              FocusScope.of(context).requestFocus(_amountFocusNode);
            },
          ),

          const SizedBox(height: 16),

          AmountTextField(
            focusNode: _amountFocusNode,
            initialAmount: widget.expense.amount, // Mevcut değeri gönderdik
            amountTextLabel: _amountLabelText,
            amountCurrencySuffix: _amountCurrencySuffix,
            amountErrorText: _amountError,
            amountHintText: "0,00",
            onAmountChanged: (value) {
              _currentAmount = value; // Widget değiştikçe bu güncellenir
            },
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
          style: TextStyle(
            fontSize: Theme.of(context).textTheme.bodyLarge?.fontSize,
            fontWeight: FontWeight.bold,
          ),
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
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: Theme.of(context).textTheme.bodySmall?.color,
          ),
        ),
      ),
    );
  }
}
