import 'package:flutter/services.dart';

class CapitalizeWordsTextFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    String capitalized = newValue.text
        .split(' ')
        .map((word) => word.isNotEmpty ? word[0].toUpperCase() + word.substring(1) : '')
        .join(' ');

    return newValue.copyWith(
      text: capitalized,
      selection: newValue.selection,
    );
  }
}
