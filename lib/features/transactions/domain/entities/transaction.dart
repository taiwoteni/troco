import 'package:equatable/equatable.dart';
import 'package:flutter/cupertino.dart';
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
  String get location =>
      _json["transaction location"] ?? _json["location"] ?? _json["address"];

  Group get group {
    return AppStorage.getGroups().firstWhere(
      (element) {
        debugPrint("group id for ${element.groupName} is ${element.groupId}");
        return element.groupId == transactionId;
      },
    );
  }

  String get sellerName {
    if (transactionPurpose == TransactionPurpose.Selling) {
      return ClientProvider.readOnlyClient!.fullName;
    }

    final seller = AppStorage.getFriends().firstWhere(
      (element) => element.userId == creator,
    );

    return seller.fullName;
  }

  String get buyerName {
    if (transactionPurpose != TransactionPurpose.Selling) {
      return ClientProvider.readOnlyClient!.fullName;
    }

    final client = AppStorage.getFriends().firstWhere(
      (element) => element.userId == buyer,
    );

    return client.fullName;
  }

  DateTime get transactionTime => DateTime.parse(_json["transaction time"] ??
      _json["DateOfWork"] ??
      group.transactionTime.toIso8601String());

  DateTime get creationTime => DateTime.parse(_json["creation time"] ??
      _json["createdAt"] ??
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

  List<SalesItem> get returnItems {
    // we call toSet().toList() to remove duplicating values
    final list = ((_json["returnedItems"] ?? []) as List).toSet().toList();
    if (list.isEmpty) {
      return [];
    }
    return (list.last["products"] as List)
        .map(
          (e) => salesItem.firstWhere(
            (element) => element.id == e.toString(),
          ),
        )
        .toList();

    // return ((_json["returnedItems"] ?? []) as List).map((e) {
    //   var product = transactionCategory == TransactionCategory.Product;
    //   return product
    //       ? Product.fromJson(json: e)
    //       : transactionCategory == TransactionCategory.Virtual
    //           ? VirtualService.fromJson(json: e)
    //           : Service.fromJson(json: e);
    // }).toList();
  }

  String get pricingName {
    if (transactionCategory == TransactionCategory.Product) {
      return "Product";
    }
    return "Service";
  }

  bool get hasReturnTransaction =>
      _json["returnedItems"] == null ? false : returnItems.isNotEmpty;

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
  bool get adminApprovesDriver => [
        TransactionStatus.Ongoing,
        TransactionStatus.Finalizing,
        TransactionStatus.Completed,
      ].contains(transactionStatus);
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
          .format(transactionAmount);

  String get escrowChargesString =>
      NumberFormat.currency(locale: 'en_NG', decimalDigits: 2, symbol: "")
          .format(escrowCharges);

  double get escrowCharges {
    double amount = salesItem
        .map((e) => e.quantity * e.escrowCharge)
        .toList()
        .fold(0, (previousValue, currentPrice) => previousValue + currentPrice);
    return amount;
  }

  double get transactionAmount {
    if (_json["transaction amount"] != null) {
      return (_json["transaction amount"]);
    }

    if (salesItem.isEmpty) {
      return 0;
    }

    double amount = salesItem
        .map((e) => e.quantity * e.finalPrice)
        .toList()
        .fold(0, (previousValue, currentPrice) => previousValue + currentPrice);
    return amount;
  }

  Map<dynamic, dynamic> toJson() {
    return _json;
  }

  Transaction copyWith({
    final TransactionStatus? transactionStatus,
  }) {
    final old = toJson();
    if (transactionStatus != null) {
      old["status"] = transactionStatus.name.toLowerCase();
    }

    return Transaction.fromJson(json: old);
  }

  Transaction clone() {
    final json = {};
    toJson().forEach((key, value) {
      json[key] = value;
    });
    return Transaction.fromJson(json: json);
  }

  @override
  List<Object?> get props => [transactionId];
}
