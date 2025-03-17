// ignore_for_file: depend_on_referenced_packages
// ignore_for_file: implementation_imports

import 'dart:developer';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:troco/features/transactions/data/models/create-transaction-data-holder.dart';
import 'package:troco/features/transactions/domain/entities/virtual-service.dart';
import 'package:troco/features/transactions/presentation/view-transaction/providers/transactions-provider.dart';
import 'package:troco/features/transactions/utils/product-quality-converter.dart';
import 'package:troco/features/transactions/utils/service-role.dart';

import '../../../groups/domain/entities/group.dart';
import '../../data/models/virtual-document.dart';
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
    var sellerId = ClientProvider.readOnlyClient!.userId;
    var buyerId = AppStorage.getGroups()
        .firstWhere((element) => element.groupId == groupId)
        .buyerId;

    /// We have to invert the sellers and buyers if the users
    /// selected that he's the Client;
    if (cat == TransactionCategory.Service &&
        (TransactionDataHolder.role ?? ServiceRole.Developer) ==
            ServiceRole.Client) {
      final buyerPlaceHolder = buyerId;
      buyerId = sellerId;
      sellerId = buyerPlaceHolder;
    }

    final result = await ApiInterface.postRequest(
        url: "createtransaction/$sellerId/$groupId/$buyerId",
        data: {
          "typeOftransaction":
              transaction.transactionCategory.name.toLowerCase(),
          "pricingType": cat == TransactionCategory.Product
              ? "pricings"
              : "${transaction.transactionCategory.name.toLowerCase()}pricing",
          // "role":"Seller",
          "transactionName": transaction.transactionName,
          "aboutService": transaction.transactionDetail,
          "role": TransactionDataHolder.role?.name.toLowerCase(),
          "location": transaction.location,
          "inspectionPeriod": transaction.inspectionPeriod.name.toLowerCase(),
          "inspectionDays": transaction.inspectionDays,
          "DateOfWork": dateOfWork,
        });

    return result;
  }

  static Future<HttpResponseModel> editTransaction(
      {required final String groupId,
      required final Transaction transaction,
      required final String dateOfWork}) async {
    final cat = transaction.transactionCategory;
    var sellerId = ClientProvider.readOnlyClient!.userId;
    var buyerId = AppStorage.getGroups()
        .firstWhere((element) => element.groupId == groupId)
        .buyerId;

    /// We have to invert the sellers and buyers if the users
    /// selected that he's the Client;
    if (cat == TransactionCategory.Service &&
        (TransactionDataHolder.role ?? ServiceRole.Developer) ==
            ServiceRole.Client) {
      final buyerPlaceHolder = buyerId;
      buyerId = sellerId;
      sellerId = buyerPlaceHolder;
    }

    final result = await ApiInterface.patchRequest(
        url: "edit_transaction/$groupId",
        data: {
          "typeOftransaction":
              transaction.transactionCategory.name.toLowerCase(),
          "pricingType": cat == TransactionCategory.Product
              ? "pricings"
              : "${transaction.transactionCategory.name.toLowerCase()}pricing",
          // "role":"Seller",
          "transactionName": transaction.transactionName,
          "aboutService": transaction.transactionDetail,
          "location": transaction.location,
          "inspectionPeriod": transaction.inspectionPeriod.name.toLowerCase(),
          "inspectionDays": transaction.inspectionDays,
          "DateOfWork": dateOfWork,
        });

    return result;
  }

  static List<MultiPartModel> editPricingMultipart({
    required final TransactionCategory type,
    required final String transactionId,
    required final SalesItem item,
  }) {
    /// We start with the default fields like,
    /// 'price', 'quantity', 'pricingImage'
    final multiparts = <MultiPartModel>[];

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

        multiparts.add(MultiPartModel.field(
            field: "deadlineTime",
            value: service.deadlineTime.toIso8601String()));
        multiparts.add(MultiPartModel.field(
            field: "description", value: service.description));

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
        multiparts.add(MultiPartModel.field(
            field: "description", value: virtual.description));
      }
    } on Exception catch (e) {
      log("Uploading Pricing$e");
    }

    return multiparts;
  }

  static Future<HttpResponseModel> editPricing({
    required final TransactionCategory type,
    required final String transactionId,
    required final Group group,
    required final SalesItem item,
  }) async {
    /// We have to loop the endpoint and the removeImages one-by-one
    /// Then after we've looped the last removeImages, we add the pricingImage

    final removedImages = item.removedImages;
    debugPrint(
        "Removed Images in item ${item.name}: ${removedImages.toString()}");

    for (final image in removedImages) {
      final multiparts = editPricingMultipart(
          type: type, transactionId: transactionId, item: item);
      multiparts.add(MultiPartModel.field(field: 'removeImages', value: image));
      final result = await ApiInterface.multipartPatchRequest(
          url: "edit_pricing/${group.groupId}/${item.id}",
          multiparts: multiparts);
      if (result.error) {
        return result;
      }
    }

    final multiparts = editPricingMultipart(
        type: type, transactionId: transactionId, item: item);
    if (!item.noImage) {
      debugPrint(
          "Added Images in item ${item.name}: ${item.images.toString()}");
      for (final image in item.images) {
        var parsedfile = File(image);
        var stream = ByteStream(parsedfile.openRead());
        var length = await parsedfile.length();
        final file = MultipartFile("pricingImage", stream, length,
            filename: Path.basename(image));

        multiparts.add(MultiPartModel.file(file: file));
      }
    }

    final result = await ApiInterface.multipartPatchRequest(
        url: "edit_pricing/${group.groupId}/${item.id}",
        multiparts: multiparts);
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

    /// We start with the default fields like,
    /// 'price', 'quantity', 'pricingImage'
    final multiparts = <MultiPartModel>[];

    if (!item.noImage) {
      for (final image in item.images) {
        var parsedfile = File(image);
        var stream = ByteStream(parsedfile.openRead());
        var length = await parsedfile.length();
        final file = MultipartFile("pricingImage", stream, length,
            filename: Path.basename(image));

        multiparts.add(MultiPartModel.file(file: file));
      }
    }

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

        multiparts.add(MultiPartModel.field(
            field: "deadlineTime",
            value: service.deadlineTime.toIso8601String()));
        multiparts.add(MultiPartModel.field(
            field: "description", value: service.description));

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
        multiparts.add(MultiPartModel.field(
            field: "description", value: virtual.description));
      }
    } on Exception catch (e) {
      log("Uploading Pricing$e");
    }

    var sellerId = ClientProvider.readOnlyClient!.userId;
    var buyerId = group.buyerId;

    /// We have to invert the sellers and buyers if the users
    /// selected that he's the Client;
    if (type == TransactionCategory.Service &&
        (TransactionDataHolder.role ?? ServiceRole.Developer) ==
            ServiceRole.Client) {
      final buyerPlaceHolder = buyerId;
      buyerId = sellerId;
      sellerId = buyerPlaceHolder;
    }

    final result = await ApiInterface.multipartPostRequest(
        url:
            "createpricing/$sellerId/${group.groupId}/${group.groupId}/$buyerId/${group.admin.userId}",
        multiparts: multiparts);
    return result;
  }

  static Future<HttpResponseModel> getEscrowCharges() async {
    final result = await ApiInterface.getRequest(url: "getcharges");

    return result;
  }

  static Future<HttpResponseModel> reportTransaction({
    required final String transactionId,
    required final String reason,
  }) async {
    return await ApiInterface.postRequest(
        url:
            'report_transaction/$transactionId/${ClientProvider.readOnlyClient?.userId}',
        data: {'reason': reason});
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
    return await ApiInterface.getRequest(
        url: 'get_user_transactions/${AppStorage.getUser()?.userId}');
  }

  /// User Data must have been saved on Cache first before [getTransactions] can be called.
  /// Else: Error will be thrown.
  Future<List<Transaction>> getTransactions() async {
    final response = await getAllTransactions();

    if (response.error) {
      log("error fetching transactions from repo");
      return AppStorage.getAllTransactions();
    } else {
      final transactionsJson = ((response.messageBody?["data"] ?? []) as List);

      final transactions =
          transactionsJson.map((e) => Transaction.fromJson(json: e)).toList();

      // for (final json in transactionsJson) {
      //   if ((json["pricing"] as List).isNotEmpty) {
      //     Transaction t = Transaction.fromJson(json: json);
      //     try {
      //       t.salesItem.length;
      //       transactions.add(t);
      //     } on TypeError {
      //       //Do nothing
      //     }
      //   }
      // }
      return transactions;
    }
  }

  static Future<HttpResponseModel> respondToTransaction({
    required final bool approve,
    required final Transaction transaction,
    required final WidgetRef ref,
  }) async {
    final result = await ApiInterface.patchRequest(
        url:
            "updateTransactionStatus/${transaction.transactionId}/${ClientProvider.readOnlyClient!.userId}/${transaction.creator}",
        data: {"status": approve ? "In Progress" : "Declined"});

    final b = ref.refresh(transactionsStreamProvider);
    b;

    return result;
  }

  static Future<HttpResponseModel> uploadDriverDetails({
    required final Driver driver,
    required final Transaction transaction,
  }) async {
    var parsedfile = File(driver.plateNumber);
    var parsedFile2 = File(driver.backPlateNumber);
    var stream = ByteStream(parsedfile.openRead());
    var stream2 = ByteStream(parsedFile2.openRead());
    var length = await parsedfile.length();
    var length2 = await parsedFile2.length();

    final file = MultipartFile("FrontPlateNumber", stream, length,
        filename: Path.basename(driver.plateNumber.toString()));
    final file2 = MultipartFile("BackPlateNumber", stream2, length2,
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
            "createdriver/${ClientProvider.readOnlyClient!.userId}/${transaction.transactionId}/${transaction.transactionId}/${transaction.group.adminId}",
        multiparts: multiparts);
    debugPrint(response.body);
    return response;
  }

  static Future<HttpResponseModel> hasReceivedProduct({
    required final Transaction transaction,
    required final bool yes,
  }) async {
    final group = transaction.group;
    final response = await ApiInterface.patchRequest(
        url:
            "updatetofinalizing/${group.groupId}/${group.buyerId}/${group.creator}",
        data: {"status": yes ? "approved" : "declined"});

    return response;
  }

  static Future<HttpResponseModel> satisfiedWithProduct({
    required final Transaction transaction,
    required final bool yes,
  }) async {
    final group = transaction.group;
    final reqParams =
        "${group.groupId}/${group.buyerId}/${group.adminId}/${group.creator}";

    final response = await ApiInterface.patchRequest(
        url: "buyer${yes ? "" : "not"}satisfied/$reqParams", data: {});

    return response;
  }

  static Future<HttpResponseModel> returnTransaction({
    required final Transaction transaction,
    required final List<String> itemIds,
    required final String comment,
  }) async {
    final response = await ApiInterface.postRequest(
        url: "returntransaction",
        okCode: 201,
        data: {
          "transactionId": transaction.transactionId,
          "comments": comment,
          "productIds": itemIds,
          "userId": ClientProvider.readOnlyClient!.userId
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

  static Future<HttpResponseModel> acceptReturnedGoods(
      {required final Transaction transaction}) async {
    return await ApiInterface.patchRequest(
        url:
            'seller_accept_returned_goods/${transaction.transactionId}/${transaction.creator}/${transaction.buyer}',
        data: {"confirmedBySeller": true});
  }

  // !!!! Service and Virtual transaction Specific endpoints !!!!

  static List<Future<HttpResponseModel>> uploadVirtualDocuments(
      {required final Transaction transaction,
      required final String taskId,
      required final List<VirtualDocument> documents}) {
    final futures = documents.map((document) {
      final isLink = document.type == VirtualDocumentType.Link;
      debugPrint("Item ${documents.indexOf(document) + 1} is Link: $isLink");
      return uploadProofOfWork(
              transaction: transaction,
              taskId: taskId,
              link: isLink,
              fileOrLink: document.source)
          .then(
        (value) {
          debugPrint(value.body);
          if (value.error) {
            throw Exception(value.messageBody?["message"] ?? "Error occurred");
          }
          return value;
        },
      );
    }).toList();

    return futures;
  }

  static Future<HttpResponseModel> uploadProofOfWork(
      {required final Transaction transaction,
      required final String taskId,
      required final bool link,
      required final String fileOrLink}) async {
    late HttpResponseModel model;

    if (link) {
      model = await ApiInterface.postRequest(
          url: "upload_each_task/$taskId",
          data: {
            "proofLinks": fileOrLink,
            "transactionType":
                transaction.transactionCategory.name.toLowerCase()
          });
      return model;
    }
    final multiparts = <MultiPartModel>[];
    var parsedfile = File(fileOrLink);
    var stream = ByteStream(parsedfile.openRead());
    var length = await parsedfile.length();
    final file = MultipartFile("proofOfWork", stream, length,
        filename: Path.basename(fileOrLink));
    multiparts.add(MultiPartModel.field(
        field: "transactionType",
        value: transaction.transactionCategory.name.toLowerCase()));

    multiparts.add(MultiPartModel.file(file: file));

    model = await ApiInterface.multipartPostRequest(
        url: "upload_each_task/$taskId", multiparts: multiparts);

    return model;
  }

  static Future<HttpResponseModel> satisfiedWithTask({
    required final Transaction transaction,
    required final Service task,
    required final bool yes,
  }) async {
    final response = await ApiInterface.patchRequest(
        url:
            "${yes ? "accept" : "reject"}_task/${transaction.transactionId}/${task.id}/${transaction.creator}/${transaction.buyer}",
        data: {
          "transactionType": transaction.transactionCategory.name.toLowerCase()
        });

    return response;
  }

  static Future<HttpResponseModel> satisfiedWithVirtualProduct({
    required final Transaction transaction,
    required final VirtualService task,
    required final bool yes,
  }) async {
    final response = await ApiInterface.patchRequest(
        url:
            "${yes ? "accept" : "reject"}_task/${transaction.transactionId}/${task.id}/${transaction.creator}/${transaction.buyer}",
        data: {
          "transactionType": transaction.transactionCategory.name.toLowerCase()
        });

    return response;
  }
}
