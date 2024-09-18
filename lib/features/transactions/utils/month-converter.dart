import 'month-enum.dart';

extension MonthConverter on Month {
  int toMonthOfYear() => Month.values.indexOf(this) + 1;

  DateTime toDateTime() =>
      DateTime(DateTime.now().year, toMonthOfYear(), DateTime.now().day);
}
