import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:limitim/features/expense/bloc/session_bloc.dart';

class SetLimitSheet extends StatefulWidget {
  const SetLimitSheet({super.key});

  @override
  State<SetLimitSheet> createState() => _SetLimitSheetState();
}

class _SetLimitSheetState extends State<SetLimitSheet> {
  final _limitController = TextEditingController();
  String? _limitError;
  final String _invalidLimitError = "Lütfen geçerli bir limit girin";
  final String _limitLabelText = "Aylık Limit";
  final String _limitHintText = "Örn: 5000";
  final String _currencySuffix = "₺";
  final String _newLimitTitle = "Yeni Limit Belirle";
  final String _newLimitDescription =
      "Bu ay için harcayabileceğiniz toplam miktarı giriniz.";
  final String _startBudgetButtonText = "Bütçeyi Başlat";
  final String _cancelButtonText = "Vazgeç";

  void _submit() {
    final limitText = _limitController.text;
    final limit = double.tryParse(limitText);

    if (limit == null || limit <= 0) {
      setState(() {
        _limitError = _invalidLimitError;
      });
    } else {
      context.read<SessionBloc>().add(StartNewSession(limit));
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      // use viewInsets to avoid keyboard overlap
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
        left: 24,
        right: 24,
        top: 24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _hintTextColumn(context),
          const SizedBox(height: 24),

          _limitTextField(),
          const SizedBox(height: 32),

          // start budget button
          _startButton(context),

          const SizedBox(height: 8),

          // cancel button
          _cancelButton(context),
        ],
      ),
    );
  }

  Column _hintTextColumn(BuildContext context) {
    return Column(
      children: [
        Text(
          _newLimitTitle,
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Text(
          _newLimitDescription,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Theme.of(
              context,
            ).colorScheme.onSurface.withValues(alpha: 0.6),
          ),
        ),
      ],
    );
  }

  TextField _limitTextField() {
    return TextField(
      controller: _limitController,
      autofocus: true, // open keyboard automatically when sheet opens
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      inputFormatters: [
        // Convert comma to dot immediately
        TextInputFormatter.withFunction((oldValue, newValue) {
          return newValue.copyWith(text: newValue.text.replaceAll(',', '.'));
        }),
      ],
      decoration: InputDecoration(
        labelText: _limitLabelText,
        hintText: _limitHintText,
        suffixText: _currencySuffix,
        errorText: _limitError,
        border: const OutlineInputBorder(),
      ),
    );
  }

  SizedBox _startButton(BuildContext context) {
    return SizedBox(
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
        child: Text(
          _startBudgetButtonText,
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
}
