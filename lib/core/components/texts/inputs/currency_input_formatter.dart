import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

class CurrencyInputFormatter extends TextInputFormatter {
  final NumberFormat currencyFormatter;

  CurrencyInputFormatter({String locale = 'en_NG'})
      : currencyFormatter = NumberFormat.currency(
          locale: locale,
          decimalDigits: 0,
          symbol: "",
        );

  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    // Remove all non-numeric characters
    String newText = newValue.text.replaceAll(RegExp(r'[^0-9]'), '');

    if (newText.isEmpty) return newValue.copyWith(text: '');

    // Parse as integer
    int value = int.parse(newText);

    // Format as integer with commas
    String formatted = currencyFormatter.format(value);

    // Keep cursor at the end
    return newValue.copyWith(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}
