import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:limitim/core/utils/currency_helper.dart';
import 'package:limitim/core/utils/integer_currency_formatter.dart';
import 'package:limitim/features/expense/bloc/session_bloc.dart';

class SetLimitSheet extends StatefulWidget {
  final double? initialLimit;
  final bool initialAutoRollover;
  const SetLimitSheet({
    super.key,
    this.initialLimit,
    this.initialAutoRollover = false,
  });

  @override
  State<SetLimitSheet> createState() => _SetLimitSheetState();
}

class _SetLimitSheetState extends State<SetLimitSheet> {
  final _limitController = TextEditingController();
  String? _limitError;
  late bool _autoRollover;

  bool get _isEditing => widget.initialLimit != null;

  final String _invalidLimitError = "Lütfen geçerli bir limit girin";
  final String _limitLabelText = "Aylık Limit";
  final String _limitHintText = "Örn: 5.000,00";
  final String _currencySuffix = "₺";
  String get _title => _isEditing ? "Limiti Güncelle" : "Yeni Limit Belirle";
  String get _description => _isEditing
      ? "Mevcut bütçe limitinizi değiştirmek için yeni miktarı giriniz."
      : "Bu ay için harcayabileceğiniz toplam miktarı giriniz.";
  String get _buttonText => _isEditing ? "Limiti Güncelle" : "Bütçeyi Başlat";
  final String _cancelButtonText = "Vazgeç";
  final String _autoRolloverTitle = "30 gün sonra otomatik devret";
  final String _autoRolloverSubtitle =
      "Süre dolduğunda mevcut dönem arşivlenir ve aynı limitle yeni dönem başlar";

  @override
  void initState() {
    super.initState();
    _autoRollover = widget.initialAutoRollover;
    if (_isEditing && widget.initialLimit != null) {
      // convert initial limit to formatted string
      final String formatted = CurrencyHelper.format(widget.initialLimit!);

      // set the formatted string to the controller
      _limitController.text = formatted;
    }
  }

  @override
  void dispose() {
    super.dispose();
    _limitController.dispose();
  }

  void _submit() {
    // parse the limit from the text field
    final cleanText = _limitController.text
        .replaceAll('.', '') // remove thousand separators
        .replaceAll(',', '.'); // replace decimal comma with dot

    final limit = double.tryParse(cleanText);

    if (limit == null || limit <= 0) {
      setState(() {
        _limitError = _invalidLimitError;
      });
    } else {
      if (_isEditing) {
        context.read<SessionBloc>().add(
          UpdateSessionLimit(limit, autoRollover: _autoRollover),
        );
      } else {
        context.read<SessionBloc>().add(
          StartNewSession(limit, autoRollover: _autoRollover),
        );
      }
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
          const SizedBox(height: 16),

          // auto-rollover checkbox
          _autoRolloverCheckbox(context),
          const SizedBox(height: 24),

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
        Text(_title, style: Theme.of(context).textTheme.displayMedium),
        const SizedBox(height: 8),
        Text(
          _description,
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
        FilteringTextInputFormatter.allow(RegExp(r'[0-9,.]')),
        IntegerCurrencyFormatter(), // add thousand separators
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

  Widget _autoRolloverCheckbox(BuildContext context) {
    return CheckboxListTile(
      value: _autoRollover,
      onChanged: (value) {
        setState(() {
          _autoRollover = value ?? false;
        });
      },
      title: Text(
        _autoRolloverTitle,
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
          fontWeight: FontWeight.w500,
        ),
      ),
      subtitle: Text(
        _autoRolloverSubtitle,
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
          color: Theme.of(
            context,
          ).colorScheme.onSurface.withValues(alpha: 0.5),
        ),
      ),
      contentPadding: EdgeInsets.zero,
      controlAffinity: ListTileControlAffinity.leading,
      dense: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
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
          _buttonText,
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
