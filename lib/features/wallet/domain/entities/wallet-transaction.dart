import 'package:intl/intl.dart';
import 'package:troco/features/transactions/utils/enums.dart';
import 'package:troco/features/wallet/utils/enums.dart';

class WalletTransaction{
  final Map<dynamic,dynamic> _json;

  const WalletTransaction.fromJson({required final Map<dynamic,dynamic> json}):_json=json;


  String get transactionName => _json["transactionName"];
  String get transactionId => _json["transactionId"];
  
  double get transactionAmount => double.parse(_json["trannsactionAmount"].toString());

  String get transactionAmountString{
    return NumberFormat.currency(locale: 'en_NG', symbol: '', decimalDigits: 2).format(transactionAmount);
  }

  WalletPurpose get transactionPurpose{
    if(_json["transactionType"] == "withdraw"){
      return WalletPurpose.Withdraw;
    }
    return WalletPurpose.Income;
  }

  TransactionStatus get transactionStatus{
    if(_json["transactionStatus"] == "pending"){
      return TransactionStatus.Pending;
    }
    return TransactionStatus.Completed;
  }


  Map<dynamic,dynamic> toJson()=> _json;

}