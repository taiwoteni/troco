class DateValidator {
  static bool isValidDate(String input, {bool? expritation}) {
    if (input.length != 10) {
      return false;
    }

    final day = int.tryParse(input.substring(0, 2));
    final month = int.tryParse(input.substring(3, 5));
    final year = int.tryParse(input.substring(6, 10));

    if (day == null || month == null || year == null) {
      return false;
    }

    if (month < 1 || month > 12) {
      return false;
    }

    if ((expritation ?? false) && month < DateTime.now().month) {
      return false;
    }
    if ((expritation ?? false) &&
        month == DateTime.now().month &&
        day < DateTime.now().day) {
      return false;
    }

    final daysInMonth = [31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31];

    if (_isLeapYear(year)) {
      daysInMonth[1] = 29; // February has 29 days in a leap year
    }

    if (day < 1 || day > daysInMonth[month - 1]) {
      return false;
    }

    return true;
  }

  static bool _isLeapYear(int year) {
    if (year % 4 != 0) {
      return false;
    }
    if (year % 100 == 0 && year % 400 != 0) {
      return false;
    }
    return true;
  }
}
