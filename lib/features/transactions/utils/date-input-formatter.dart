import 'package:flutter/services.dart';

class DateInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    // Only allow digits and slashes
    final text = newValue.text.replaceAll(RegExp(r'[^0-9/]'), '');

    // Split the text by slashes
    final parts = text.split('/');

    String newText = '';
    for (int i = 0; i < parts.length; i++) {
      if (i == 0 && parts[i].length > 2) {
        newText += '${parts[i].substring(0, 2)}/';
        if (parts[i].length > 2) {
          newText += parts[i].substring(2);
        }
      } else if (i == 1 && parts[i].length > 2) {
        newText += '${parts[i].substring(0, 2)}/';
        if (parts[i].length > 2) {
          newText += parts[i].substring(2);
        }
      } else {
        newText += parts[i];
        if (i < parts.length - 1) {
          newText += '/';
        }
      }
    }

    // Limit to 10 characters
    if (newText.length > 10) {
      newText = newText.substring(0, 10);
    }

    // Create a new TextEditingValue with the formatted text
    return newValue.copyWith(
      text: newText,
      selection: TextSelection.collapsed(offset: newText.length),
    );
  }
}
