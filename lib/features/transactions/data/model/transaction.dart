
import '../../utils/enums.dart';
import '../../utils/transaction-purpose-converter.dart';
import '../../utils/transaction-status-converter.dart';

class Transaction {
  final Map<dynamic, dynamic> _json;
  const Transaction.fromJson({required final Map<dynamic, dynamic> json})
      : _json = json;

  String get transactionDetail => _json["transaction detail"];
  DateTime get transactionTime => DateTime.parse(_json["transaction time"]);
  String get id => _json["transaction id"];
  TransactionPurpose get transactionPurpose =>
      TransactionPurposeConverter.convertToEnum(purpose: _json["transaction purpose"]);
  TransactionStatus get transactionStatus =>
      TransactionConverter.convertToStatus(status: _json["transaction status"]);

  /// We have to think these through as a transaction can have many products.
  String get productCategory => _json["product category"];
  String get productName => _json["product name"];
  String get productDetail => _json["product detail"];
  ProductCondition get productCondition =>
      // TransactionConverter.convertToCondition(
      //     condition: _json["product condition"])
      ProductCondition.New;
  double get transactionAmount => _json["transaction amount"];
}
