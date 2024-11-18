import 'package:intl/intl.dart';

extension StringExtension on String {
  String ellipsize(int maxLength, {int ellipsizeLength = 3}) {
    if (length <= maxLength) {
      return this;
    }
    if (length - ellipsizeLength <= 0) {
      return this;
    }

    return substring(0, maxLength - ellipsizeLength)
        .padRight(ellipsizeLength, ".");
  }
}

extension NullStringExtensions on int? {
  String? format(NumberFormat format) {
    return this == null ? null : format.format(this);
  }
}
