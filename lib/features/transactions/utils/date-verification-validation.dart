class DateValidator {
  static bool isValidDate(String input) {
    // Ensure the input matches the dd/MM/yyyy pattern
    final datePattern = RegExp(r'^\d{2}/\d{2}/\d{4}$');
    if (!datePattern.hasMatch(input)) {
      return false;
    }

    // Parse the input to a DateTime object
    final parts = input.split('/');
    final day = int.tryParse(parts[0]);
    final month = int.tryParse(parts[1]);
    final year = int.tryParse(parts[2]);

    if (day == null || month == null || year == null) {
      return false;
    }

    // Check if the date is valid
    try {
      final date = DateTime(year, month, day);
      return date.year == year && date.month == month && date.day == day;
    } catch (e) {
      return false;
    }
  }
}
