import 'package:intl/intl.dart';
import 'package:troco/features/transactions/utils/enums.dart';
import 'package:troco/features/wallet/utils/enums.dart';

class WalletTransaction {
  final Map<dynamic, dynamic> _json;

  const WalletTransaction.fromJson({required final Map<dynamic, dynamic> json})
      : _json = json;

  String get transactionName => _json["transactionName"] ?? _json["content"];
  String get transactionId => _json["transactionId"] ?? _json["_id"];

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
    if ((_json["transactionStatus"] ?? _json["status"])
            ?.toString()
            .toLowerCase() ==
        "pending") {
      return TransactionStatus.Pending;
    }
    if ((_json["transactionStatus"] ?? _json["status"])
            ?.toString()
            .toLowerCase() ==
        "declined") {
      return TransactionStatus.Cancelled;
    }
    return TransactionStatus.Completed;
  }

  DateTime get time {
    return DateTime.parse(_json["date"] ?? DateTime.now().toIso8601String())
        .toLocal();
  }

  Map<dynamic, dynamic> toJson() => _json;
}
