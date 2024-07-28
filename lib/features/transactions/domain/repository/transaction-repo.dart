// ignore_for_file: depend_on_referenced_packages
// ignore_for_file: implementation_imports

import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:troco/features/transactions/domain/entities/virtual-service.dart';
import 'package:troco/features/transactions/utils/product-quality-converter.dart';

import '../../../groups/domain/entities/group.dart';
import '../entities/driver.dart';
import '../entities/service.dart';
import "package:path/path.dart" as Path;
import 'package:http/http.dart';
import 'package:troco/core/api/data/model/multi-part-model.dart';
import 'package:troco/core/api/data/repositories/api-interface.dart';
import 'package:troco/core/cache/shared-preferences.dart';
import 'package:troco/features/auth/presentation/providers/client-provider.dart';
import 'package:troco/features/transactions/domain/entities/product.dart';
import 'package:troco/features/transactions/domain/entities/sales-item.dart';
import 'package:troco/features/transactions/domain/entities/transaction.dart';
import 'package:troco/features/transactions/utils/enums.dart';
import 'package:troco/features/transactions/utils/product-condition-converter.dart';

import '../../../../core/api/data/model/response-model.dart';

class TransactionRepo {
  static Future<HttpResponseModel> createTransaction(
      {required final String groupId,
      required final Transaction transaction,
      required final String dateOfWork}) async {
    final cat = transaction.transactionCategory;
    final result = await ApiInterface.postRequest(
        url:
            "createtransaction/${ClientProvider.readOnlyClient!.userId}/$groupId",
        data: {
          "typeOftransaction":
              transaction.transactionCategory.name.toLowerCase(),
          "pricingType": cat == TransactionCategory.Product
              ? "pricings"
              : "${transaction.transactionCategory.name.toLowerCase()}pricing",
          // "role":"Seller",
          "transactionName": transaction.transactionName,
          "aboutService": transaction.transactionDetail,
          "location": ClientProvider.readOnlyClient!.address,
          "inspectionPeriod": transaction.inspectionPeriod.name.toLowerCase(),
          "inspectionDays": transaction.inspectionDays,
          "DateOfWork": dateOfWork,
        });

    return result;
  }

  static Future<HttpResponseModel> createPricing({
    required final TransactionCategory type,
    required final String transactionId,
    required final Group group,
    required final SalesItem item,
  }) async {
    /// As we all know, there are 3 types of Transactions.
    /// Virtual, Service and Product

    log(type.name.toString());

    var parsedfile = File(item.image);
    var stream = ByteStream(parsedfile.openRead());
    var length = await parsedfile.length();
    final file = MultipartFile("pricingImage", stream, length,
        filename: Path.basename(item.image.toString()));

    /// We start with the default fields like,
    /// 'price', 'quantity', 'pricingImage'
    final multiparts = <MultiPartModel>[];
    multiparts.add(MultiPartModel.file(file: file));
    multiparts.add(MultiPartModel.field(field: "price", value: item.price));
    multiparts
        .add(MultiPartModel.field(field: "quantity", value: item.quantity));

    try {
      /// For Service Transactions, we have:
      /// 'serviceName', 'serviceRequirement'
      if (type == TransactionCategory.Service) {
        final service = item as Service;
        log("Is Service");

        final serviceName =
            MultiPartModel.field(field: "serviceName", value: service.name);
        final serviceRequirement = MultiPartModel.field(
            field: "serviceRequirement",
            value: service.serviceRequirement.name.toLowerCase());

        multiparts.add(serviceName);
        multiparts.add(serviceRequirement);
      }

      ///Now we go the interesting parts;
      /// For Product Transactions, we have:
      /// 'productName', 'productCondition', 'category' (Which is now quality. Finbarr's laziness. :|)

      else if (type == TransactionCategory.Product) {
        final product = item as Product;
        log("Is Production");

        final productName =
            MultiPartModel.field(field: "productName", value: product.name);
        final productQuality = MultiPartModel.field(
            field: "category",
            value: ProductQualityConverter.convertToString(
                quality: product.productQuality));
        final productCondition = MultiPartModel.field(
            field: "productCondition",
            value: ProductConditionConverter.convertToString(
                condition: product.productCondition));

        multiparts.add(productName);
        multiparts.add(productQuality);
        multiparts.add(productCondition);
      }

      /// For Virtual Service Transactions, we have:
      /// 'virtualName', 'virtualRequirement'

      else if (type == TransactionCategory.Virtual) {
        final virtual = item as VirtualService;
        log("Is Virtual");

        final virtualName =
            MultiPartModel.field(field: "virtualName", value: virtual.name);
        final virtualRequirement = MultiPartModel.field(
            field: "virtualRequirement",
            value: virtual.serviceRequirement.name.toLowerCase());

        multiparts.add(virtualName);
        multiparts.add(virtualRequirement);
      }
    } on Exception catch (e) {
      log("Uploading Pricing$e");
    }

    final result = await ApiInterface.multipartPostRequest(
        url:
            "createpricing/${ClientProvider.readOnlyClient!.userId}/${group.groupId}/${group.groupId}/${group.buyer!.userId}/${group.admin.userId}",
        multiparts: multiparts);
    return result;
  }

  static Future<HttpResponseModel> getOneTransaction({
    required final String transactionId,
  }) async {
    final response = await ApiInterface.getRequest(
      url: "getOneTransaction/$transactionId",
    );
    // log(response.body);

    return response;
  }

  /// User Data must have been saved on Cache first before [getAllTransactions] can be called.
  /// Else: Error will be thrown.
  static Future<HttpResponseModel> getAllTransactions() async {
    final result = await ApiInterface.findUser(
        userId: ClientProvider.readOnlyClient!.userId);

    if (result.error) {
      return HttpResponseModel(
          returnHeaderType: result.returnHeaderType,
          error: true,
          body: result.body,
          code: result.code);
    }

    final transactionsJson = result.messageBody!["data"]["transactions"] ?? [];
    // log(transactionsJson.toString());

    final List<String> transactionsId = ((transactionsJson ?? []) as List)
        .where(
          (element) => (element["pricing"] as List).isNotEmpty,
        )
        .map((e) => e["_id"].toString())
        .toList();

    List<Map<dynamic, dynamic>> jsonData = [];
    for (final String id in transactionsId) {
      final response = await getOneTransaction(transactionId: id);
      // log(response.body);
      if (response.error) {
        return HttpResponseModel(
            error: response.error, body: response.body, code: response.code);
      }

      final data = response.messageBody!["data"];
      jsonData.add(data);
    }

    return HttpResponseModel(
        returnHeaderType: result.returnHeaderType,
        error: false,
        body: json.encode(jsonData),
        code: result.code);
  }

  /// User Data must have been saved on Cache first before [getTransactions] can be called.
  /// Else: Error will be thrown.
  Future<List<Transaction>> getTransactions() async {
    final response = await getAllTransactions();

    if (response.error) {
      log("error fetching transactions from repo");
      return AppStorage.getTransactions();
    } else {
      final transactionsJson = (json.decode(response.body) as List);

      final transactions = <Transaction>[];

      for (final json in transactionsJson) {
        if ((json["pricing"] as List).isNotEmpty) {
          Transaction t = Transaction.fromJson(json: json);
          try {
            t.salesItem.length;
            transactions.add(t);
          } on TypeError {
            //Do nothing
          }
        }
      }
      return transactions;
    }
  }

  static Future<HttpResponseModel> respondToTransaction({
    required final bool approve,
    required final Transaction transaction,
  }) async {
    final result = await ApiInterface.patchRequest(
        url:
            "updateTransactionStatus/${transaction.transactionId}/${ClientProvider.readOnlyClient!.userId}/${transaction.creator}",
        data: {"status": approve ? "In Progress" : "Declined"});

    return result;
  }

  static Future<HttpResponseModel> uploadDriverDetails({
    required final Driver driver,
    required final Group group,
  }) async {
    var parsedfile = File(driver.plateNumber);
    var stream = ByteStream(parsedfile.openRead());
    var length = await parsedfile.length();
    final file = MultipartFile("FrontPlateNumber", stream, length,
        filename: Path.basename(driver.plateNumber.toString()));
    final file2 = MultipartFile("BackPlateNumber", stream, length,
        filename: Path.basename(driver.backPlateNumber.toString()));

    final multiparts = <MultiPartModel>[];
    multiparts
        .add(MultiPartModel.field(field: "name", value: driver.driverName));
    multiparts.add(
        MultiPartModel.field(field: "phoneNumber", value: driver.phoneNumber));
    multiparts.add(MultiPartModel.field(
        field: "EstimatedDeliveryTime",
        value: driver.estimatedDeliveryTime.toIso8601String()));
    multiparts.add(MultiPartModel.field(
        field: "theDelivery", value: driver.destinationLocation));
    multiparts.add(
        MultiPartModel.field(field: "CompanyName", value: driver.companyName));
    multiparts.add(MultiPartModel.file(file: file));
    multiparts.add(MultiPartModel.file(file: file2));

    final response = await ApiInterface.multipartPostRequest(
        url:
            "createdriver/${ClientProvider.readOnlyClient!.userId}/${group.groupId}/${group.groupId}/${group.adminId}",
        multiparts: multiparts);
    return response;
  }

  static Future<HttpResponseModel> hasReceivedProduct({
    required final Group group,
    required final bool yes,
  }) async {
    final response = await ApiInterface.patchRequest(
        url:
            "updatetofinalizing/${group.groupId}/${group.buyer!.userId}/${group.seller.userId}",
        data: {"status": yes ? "approved" : "declined"});

    return response;
  }

  static Future<HttpResponseModel> satisfiedWithProduct({
    required final Group group,
    required final bool yes,
  }) async {
    final reqParams =
        "${group.groupId}/${group.buyerId}/${group.adminId}/${group.creator}";

    final response = await ApiInterface.patchRequest(
        url: "buyer${yes ? "" : "not"}satisfied/$reqParams", data: {});

    return response;
  }

  static Future<HttpResponseModel> returnTransaction({
    required final Transaction transaction,
    required final List<String> itemIds,
  }) async {
    final response = await ApiInterface.postRequest(
        url: "returntransaction",
        data: {
          "transactionId":transaction.transactionId,
          "comments":"Not Satisfied With Products",
          "productIds":itemIds,
          "userId":ClientProvider.readOnlyClient!.userId
        });

    return response;
  }

  static Future<HttpResponseModel> finalizeVirtualTransaction({
    required final Transaction transaction,
    required final bool yes,
  }) async {
    final response = await ApiInterface.patchRequest(
        url:
            "finalizevirtualtransaction/${transaction.transactionId}/${transaction.buyer}/${transaction.creator}",
        data: {"status": yes ? "approved" : "no"});

    return response;
  }

  static Future<HttpResponseModel> createLeadingTransaction({
    required final Transaction transaction,
  }) async {
    final response = await ApiInterface.patchRequest(
        url: "sellerleads/${transaction.transactionId}/${transaction.creator}",
        data: {"status": "approved"});

    return response;
  }

  static Future<HttpResponseModel> startLeadingTransaction({
    required final Transaction transaction,
    required final bool yes,
  }) async {
    final response = await ApiInterface.patchRequest(
        url:
            "startledingtransaction/${transaction.transactionId}/${transaction.buyer}/${transaction.creator}",
        data: {"status": yes ? "approved" : "no"});

    return response;
  }
}
