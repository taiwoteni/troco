import 'package:equatable/equatable.dart';
import 'package:intl/intl.dart';
import 'package:troco/features/auth/presentation/providers/client-provider.dart';
import 'package:troco/features/transactions/domain/entities/driver.dart';
import 'package:troco/features/transactions/domain/entities/product.dart';
import 'package:troco/features/transactions/domain/entities/sales-item.dart';
import 'package:troco/features/transactions/domain/entities/service.dart';
import 'package:troco/features/transactions/domain/entities/virtual-service.dart';
import 'package:troco/features/transactions/utils/inspection-period-converter.dart';
import 'package:troco/features/transactions/utils/transaction-category-converter.dart';

import '../../../../core/cache/shared-preferences.dart';
import '../../../groups/domain/entities/group.dart';
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

  Group get group{
    return AppStorage.getGroups().firstWhere((element) => element.groupId ==transactionId,);
  }

  DateTime get transactionTime =>
      DateTime.parse(_json["transaction time"] ?? _json["DateOfWork"]);

  DateTime get creationTime => DateTime.parse(_json["creation time"] ??
      _json["createdTime"] ?? _json["timestamp"] ?? _json["createdAt"]??
      DateTime.now().toIso8601String());

  String get transactionId => _json["transaction id"] ?? _json["_id"];

  int get inspectionDays => int.parse(_json["inspectionDays"].toString());

  String get address =>
      _json["location"] ?? _json["address"] ?? "No address yet";

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
      TransactionStatusConverter.convertToStatus(
          status: _json["transaction status"] ?? _json["status"] ?? "pending");

  /// We have to think these through as a transaction can have many products.
  List<SalesItem> get salesItem {
    return ((_json["products"] ?? _json["pricing"]) as List).map((e) {
      var product = transactionCategory == TransactionCategory.Product;
      return product
          ? Product.fromJson(json: e)
          : transactionCategory == TransactionCategory.Virtual
              ? VirtualService.fromJson(json: e)
              : Service.fromJson(json: e);
    }).toList();
  }

  String? get adminId => _json["adminId"];
  String get buyer => _json["buyer"];

  bool get hasAdmin => _json.containsKey("adminId") ? adminId != null : false;

  Driver get driver =>
      Driver.fromJson(json: (_json["driverInformation"] as List)[0]);

  bool get hasDriver => ((_json["driverInformation"] ?? []) as List).isNotEmpty;

  bool get hasAccountDetails =>
      ((_json["accountDetailes"] ?? []) as List).isNotEmpty;

  bool get paymentDone => _json["paymentMade"] ?? false;
  bool get adminApprovesPayment => _json["adminPaymentApproved"] ?? false;
  bool get adminApprovesDriver => false;
  bool get buyerSatisfied => _json["buyerSatisfied"] ?? false;
  bool get trocoPaysSeller => _json["trocopaidSeller"] ?? false;

  bool get leadStarted =>
      [
        TransactionStatus.Ongoing,
        TransactionStatus.Finalizing,
        TransactionStatus.Completed
      ].contains(transactionStatus) &&
      sellerStarteedLeading;
  bool get sellerStarteedLeading => _json["sellerStartLeading"] ?? false;

  String get transactionAmountString =>
      NumberFormat.currency(locale: 'en_NG', decimalDigits: 2, symbol: "")
          .format(transactionAmount * 1.05);

  double get transactionAmount {
    if (_json["transaction amount"] != null) {
      return (_json["transaction amount"]);
    }

    if (salesItem.isEmpty) {
      return 0;
    }

    int amount = salesItem
        .map((e) => e.quantity * e.price)
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
