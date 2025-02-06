import 'package:intl/intl.dart';
import 'package:troco/features/transactions/utils/enums.dart';
import 'package:troco/features/wallet/utils/enums.dart';

class WalletTransaction {
  final Map<dynamic, dynamic> _json;

  const WalletTransaction.fromJson({required final Map<dynamic, dynamic> json})
      : _json = json;

  String get transactionName => _json["transactionName"] ?? _json["content"];
  String get transactionId => _json["transactionId"] ?? _json["_id"];

  String get walletId => _json["_id"];

  double get transactionAmount =>
      double.parse((_json["transactionAmount"] ?? _json["amount"]).toString());

  String get transactionAmountString {
    return NumberFormat.currency(locale: 'en_NG', symbol: '', decimalDigits: 2)
        .format(transactionAmount);
  }

  WalletPurpose get transactionPurpose {
    if ((_json["transactionType"] ?? _json["walletType"])
            .toString()
            .toLowerCase() ==
        "withdrawal") {
      return WalletPurpose.Withdraw;
    }
    return WalletPurpose.Income;
  }

  TransactionStatus get transactionStatus {
    if (transactionPurpose == WalletPurpose.Income) {
      return TransactionStatus.Completed;
    }

    final status =
        (_json["transactionStatus"] ?? _json["status"] ?? "pending") as String;

    if (["disapproved", "declined"].contains(status.toLowerCase())) {
      return TransactionStatus.Cancelled;
    }

    if (status.toLowerCase() == "pending") {
      return TransactionStatus.Pending;
    }

    if (["approved", "completed"].contains(status.toLowerCase())) {
      return TransactionStatus.Completed;
    }

    return TransactionStatus.Cancelled;
  }

  DateTime get time {
    return DateTime.parse(_json["walletUpdateTime"] ??
            _json["createdTime"] ??
            _json["date"] ??
            _json["data"] ??
            DateTime.now().toIso8601String())
        .toLocal();
  }

  DateTime get timeToSort => createdTime.isAfter(time) ? createdTime : time;

  DateTime get createdTime {
    return DateTime.parse(_json["createdTime"] ??
            _json["date"] ??
            _json["data"] ??
            DateTime.now().toIso8601String())
        .toLocal();
  }

  Map<dynamic, dynamic> toJson() => _json;
}
