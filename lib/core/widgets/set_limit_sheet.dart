import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:limitim/core/utils/currency_formatter.dart';
import 'package:limitim/features/expense/bloc/session_bloc.dart';

class SetLimitSheet extends StatefulWidget {
  final double? initialLimit;
  const SetLimitSheet({super.key, this.initialLimit});

  @override
  State<SetLimitSheet> createState() => _SetLimitSheetState();
}

class _SetLimitSheetState extends State<SetLimitSheet> {
  final _limitController = TextEditingController();
  String? _limitError;

  bool get _isEditing => widget.initialLimit != null;

  final String _invalidLimitError = "Lütfen geçerli bir limit girin";
  final String _limitLabelText = "Aylık Limit";
  final String _limitHintText = "Örn: 5000";
  final String _currencySuffix = "₺";
  String get _title => _isEditing ? "Limiti Güncelle" : "Yeni Limit Belirle";
  String get _description => _isEditing
      ? "Mevcut bütçe limitinizi değiştirmek için yeni miktarı giriniz."
      : "Bu ay için harcayabileceğiniz toplam miktarı giriniz.";
  String get _buttonText => _isEditing ? "Limiti Güncelle" : "Bütçeyi Başlat";
  final String _cancelButtonText = "Vazgeç";

  @override
  void initState() {
    super.initState();
    if (_isEditing) {
      _limitController.text = widget.initialLimit.toString();
    }
  }

  void _submit() {
    // 1. Görsel formatı temizle: Noktaları sil, virgülü noktaya çevir
    final cleanText = _limitController.text
        .replaceAll('.', '') // Binlik ayırıcı noktaları kaldır
        .replaceAll(
          ',',
          '.',
        ); // Ondalık virgülü noktaya çevir (Dart double için nokta ister)

    final limit = double.tryParse(cleanText);

    if (limit == null || limit <= 0) {
      setState(() {
        _limitError = _invalidLimitError;
      });
    } else {
      
      if (_isEditing) {
        context.read<SessionBloc>().add(UpdateSessionLimit(limit));
      } else {
        context.read<SessionBloc>().add(StartNewSession(limit));
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
        FilteringTextInputFormatter.allow(RegExp(r'[\d,]')),
        CurrencyFormatter(), // Yazarken noktaları/virgülleri koy
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
