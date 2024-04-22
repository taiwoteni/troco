import 'package:equatable/equatable.dart';
import 'package:troco/features/transactions/domain/entities/product.dart';
import 'package:troco/features/transactions/utils/transaction-category-converter.dart';

import '../../utils/enums.dart';
import '../../utils/transaction-purpose-converter.dart';
import '../../utils/transaction-status-converter.dart';

class Transaction extends Equatable {
  final Map<dynamic, dynamic> _json;
  const Transaction.fromJson({required final Map<dynamic, dynamic> json})
      : _json = json;

  String get transactionDetail => _json["transaction detail"];
  String get transactionName => _json["transaction name"];

  DateTime get transactionTime => DateTime.parse(_json["transaction time"]);
  String get transactionId => _json["transaction id"];
  TransactionCategory get transactionCategory =>
      TransactionCategoryConverter.convertToEnum(
          category: _json["transaction category"]);
  TransactionPurpose get transactionPurpose =>
      TransactionPurposeConverter.convertToEnum(
          purpose: _json["transaction purpose"]);
  TransactionStatus get transactionStatus =>
      TransactionConverter.convertToStatus(status: _json["transaction status"]);

  /// We have to think these through as a transaction can have many products.
  List<Product> get products{
    return (_json["products"] as List).map((e) => Product.fromJson(json: e)).toList();
  }

  // String get productCategory => _json["product category"];
  // String get productName => _json["product name"];
  // String get productDetail => _json["product detail"];
  // ProductCondition get productCondition =>
  //     // TransactionConverter.convertToCondition(
  //     //     condition: _json["product condition"])
  //     ProductCondition.New;
  double get transactionAmount => _json["transaction amount"];

  @override
  List<Object?> get props => [transactionId];
}
