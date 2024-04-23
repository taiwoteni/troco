import 'package:equatable/equatable.dart';
import 'package:intl/intl.dart';
import 'package:troco/features/auth/presentation/providers/client-provider.dart';
import 'package:troco/features/transactions/domain/entities/product.dart';
import 'package:troco/features/transactions/utils/inspection-period-converter.dart';
import 'package:troco/features/transactions/utils/transaction-category-converter.dart';

import '../../utils/enums.dart';
import '../../utils/transaction-purpose-converter.dart';
import '../../utils/transaction-status-converter.dart';

class Transaction extends Equatable {
  final Map<dynamic, dynamic> _json;
  const Transaction.fromJson({required final Map<dynamic, dynamic> json})
      : _json = json;

  String get transactionDetail =>
      _json["transaction detail"] ?? _json["aboutService"];
  String get transactionName =>
      _json["transaction name"] ?? _json["transactionName"];

  DateTime get transactionTime =>
      DateTime.parse(_json["transaction time"] ?? _json["DateOfWork"]);

  String get transactionId => _json["transaction id"] ?? _json["_id"];

  int get inspectionDays => int.parse(_json["inspectionDays"].toString());

  String get creator => _json["creator"];

  InspectionPeriod get inspectionPeriod =>
      InspectionPeriodConverter.converToEnum(
          inspectionPeriod: _json["inspectionPeriod"]);

  String get inspectionString {
    return "$inspectionDays ${inspectionPeriod.name}${inspectionDays == 1 ? "" : "s"}";
  }

  TransactionCategory get transactionCategory =>
      TransactionCategoryConverter.convertToEnum(
          category:
              _json["transaction category"] ?? _json["typeOftransaction"]);

  TransactionPurpose get transactionPurpose =>
      TransactionPurposeConverter.convertToEnum(
          purpose: _json["transaction purpose"] ??
              (_json["creator"].toString().toLowerCase() !=
                      ClientProvider.readOnlyClient!.userId
                  ? "buying"
                  : "selling"));

  TransactionStatus get transactionStatus =>
      TransactionConverter.convertToStatus(
          status: _json["transaction status"] ?? _json["status"] ?? "pending");

  /// We have to think these through as a transaction can have many products.
  List<Product> get products {
    return ((_json["products"] ?? _json["pricing"]) as List)
        .map((e) => Product.fromJson(json: e))
        .toList();
  }

  String get transactionAmountString =>
      NumberFormat.currency(locale: 'en_NG', decimalDigits: 2, symbol: "")
          .format(transactionAmount);

  double get transactionAmount {
    if (_json["transaction amount"] != null) {
      return _json["transaction amount"];
    }

    if (products.isEmpty) {
      return 0;
    }

    int amount = products
        .map((e) => e.quantity * e.productPrice)
        .toList()
        .fold(0, (previousValue, currentPrice) => previousValue + currentPrice);
    return amount.toDouble();
  }

  Map<dynamic, dynamic> toJson() {
    return _json;
  }

  @override
  List<Object?> get props => [transactionId];
}
