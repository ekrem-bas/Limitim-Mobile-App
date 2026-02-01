import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:limitim/core/utils/decimal_currency_formatter.dart';
import 'package:limitim/core/utils/integer_currency_formatter.dart';

class AmountTextField extends StatefulWidget {
  final FocusNode? focusNode;
  final String amountTextLabel;
  final String amountCurrencySuffix;
  final String? amountErrorText;
  final String amountHintText;
  final ValueChanged<double?> onAmountChanged;
  // for update expense
  final double? initialAmount;

  const AmountTextField({
    super.key,
    required this.amountTextLabel,
    required this.amountCurrencySuffix,
    this.amountErrorText,
    required this.amountHintText,
    required this.onAmountChanged,
    this.initialAmount,
    this.focusNode,
  });

  @override
  State<AmountTextField> createState() => _AmountTextFieldState();
}

class _AmountTextFieldState extends State<AmountTextField> {
  final TextEditingController _intController = TextEditingController();

  final TextEditingController _decimalController = TextEditingController();

  late final FocusNode _intFocusNode;
  final FocusNode _decimalFocusNode = FocusNode();

  static const String zws = '\u200B'; // Zero Width Space

  @override
  void initState() {
    super.initState();
    // if initial amount is provided, set the controllers accordingly
    _setupInitialValue();

    _intFocusNode = widget.focusNode ?? FocusNode();

    _setupIntCursor();

    _setupDecimalCursor();

    // to change border color on focus
    _intFocusNode.addListener(() => setState(() {}));
    _decimalFocusNode.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _intController.dispose();
    _decimalController.dispose();
    _intFocusNode.dispose();
    _decimalFocusNode.dispose();
    super.dispose();
  }

  void _setupInitialValue() {
    // if initial amount is provided, set the controllers accordingly
    if (widget.initialAmount != null) {
      // double -> "1250.50"
      String fixedValue = widget.initialAmount!.toStringAsFixed(2);
      List<String> parts = fixedValue.split('.');

      // format integer part with thousand separators
      final formatter = NumberFormat('#,###', 'tr_TR');
      _intController.text = formatter.format(int.parse(parts[0]));

      // decimal part with zws
      _decimalController.text = "$zws${parts[1]}";
    } else {
      _intController.text = "0";
      _decimalController.text = "${zws}00";
    }
  }

  void _setupDecimalCursor() {
    _decimalFocusNode.addListener(() {
      // if focus on decimal field and text is default (zws00), move cursor to after zws
      if (_decimalFocusNode.hasFocus && _decimalController.text == "${zws}00") {
        // Bir frame bekleyip imleci konumlandır (çakışmaları önlemek için)
        Future.microtask(() {
          _decimalController.selection = const TextSelection.collapsed(
            offset: 1,
          );
        });
      }
    });
  }

  void _setupIntCursor() {
    _intFocusNode.addListener(() {
      // if focus on integer field
      if (_intFocusNode.hasFocus) {
        // if value is "0", move cursor to start
        if (_intController.text == "0") {
          // wait for a frame to avoid rendering conflicts
          Future.microtask(() {
            _intController.selection = const TextSelection.collapsed(offset: 0);
          });
        } else {
          // if value is not "0", move cursor to end
          Future.microtask(() {
            _intController.selection = TextSelection.collapsed(
              offset: _intController.text.length,
            );
          });
        }
      }
    });
  }

  void _notifyValueChanged() {
    String intPart = _intController.text.replaceAll('.', '');
    String decimalPart = _decimalController.text.replaceAll(zws, '');

    // if decimal part is empty, consider it as "00"
    double? totalAmount = double.tryParse('$intPart.$decimalPart');

    widget.onAmountChanged(totalAmount);
  }

  void _intFieldOnTap() {
    // if integer field is tapped and text is "0", move cursor to start
    if (_intController.text == "0") {
      _intController.selection = const TextSelection.collapsed(offset: 0);
    } else {
      _intController.selection = TextSelection.collapsed(
        offset: _intController.text.length,
      );
    }
  }

  void _intFieldOnChanged(String value) {
    // if there is a comma in integer field, remove it and change focus to decimal field
    if (value.endsWith(",")) {
      _intController.text = value.substring(0, value.length - 1);
      _decimalFocusNode.requestFocus();
    }
    _notifyValueChanged();
  }

  void _decimalFieldOnTap() {
    // if decimal field is tapped and text is default, move cursor to the start of the "00"
    if (_decimalController.text == "${zws}00") {
      _decimalController.selection = const TextSelection.collapsed(offset: 1);
    }
    // else move cursor to the end
    else {
      _decimalController.selection = TextSelection.collapsed(
        offset: _decimalController.text.length,
      );
    }
  }

  void _decimalFieldOnChanged(String value) {
    // if decimal field is 00 and deleted again, reset to zws00 and change focus to integer field
    if (!value.startsWith(zws)) {
      _intFocusNode.requestFocus();
      _decimalController.text = "${zws}00";
      _decimalController.selection = const TextSelection.collapsed(offset: 1);
      return;
    }

    _notifyValueChanged();
  }

  @override
  Widget build(BuildContext context) {
    final bool isFocused = _intFocusNode.hasFocus || _decimalFocusNode.hasFocus;
    return InputDecorator(
      isFocused: isFocused,
      decoration: InputDecoration(
        labelText: widget.amountTextLabel,
        errorText: widget.amountErrorText,
        border: const OutlineInputBorder(),
        // İçerideki padding'i sıfırlıyoruz ki kontrol bizde olsun
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // integer text field
          Expanded(
            flex: 4,
            child: TextField(
              focusNode: _intFocusNode,
              controller: _intController,
              keyboardType: TextInputType.numberWithOptions(decimal: true),
              textAlign: TextAlign.end,
              style: TextStyle(
                fontSize: Theme.of(context).textTheme.titleLarge?.fontSize,
              ),
              decoration: InputDecoration(
                border: InputBorder.none,
                isDense: true,
              ),
              onTap: _intFieldOnTap,
              onChanged: _intFieldOnChanged,
              inputFormatters: [IntegerCurrencyFormatter()],
            ),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 4),
            child: Text(
              ",",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ),
          // decimal text field
          Expanded(
            flex: 1,
            child: TextField(
              focusNode: _decimalFocusNode,
              controller: _decimalController,
              textAlign: TextAlign.start,
              keyboardType: TextInputType.number,
              style: TextStyle(
                fontSize: Theme.of(context).textTheme.titleLarge?.fontSize,
              ),
              inputFormatters: [DecimalCurrencyFormatter(zws: zws)],
              onTap: _decimalFieldOnTap,
              onChanged: _decimalFieldOnChanged,
              decoration: InputDecoration(
                border: InputBorder.none, // Kutuyu gizle
                isDense: true,
                counterText: "",
                suffixIcon: Padding(
                  padding: const EdgeInsets.only(left: 4, top: 2),
                  child: Text(
                    widget.amountCurrencySuffix,
                    style: TextStyle(
                      color: Colors.grey.shade700,
                      fontSize: Theme.of(
                        context,
                      ).textTheme.titleLarge?.fontSize,
                    ),
                  ),
                ),
                suffixIconConstraints: const BoxConstraints(
                  minWidth: 0,
                  minHeight: 0,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
