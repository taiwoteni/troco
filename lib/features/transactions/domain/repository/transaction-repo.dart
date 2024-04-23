// ignore_for_file: depend_on_referenced_packages
// ignore_for_file: implementation_imports

import 'dart:convert';
import 'dart:developer';
import "package:path/path.dart" as Path;
import 'package:http/http.dart';
import 'package:http_parser/src/media_type.dart';
import 'package:troco/core/api/data/model/multi-part-model.dart';
import 'package:troco/core/api/data/repositories/api-interface.dart';
import 'package:troco/core/cache/shared-preferences.dart';
import 'package:troco/features/auth/presentation/providers/client-provider.dart';
import 'package:troco/features/transactions/domain/entities/product.dart';
import 'package:troco/features/transactions/domain/entities/transaction.dart';

import '../../../../core/api/data/model/response-model.dart';

class TransactionRepo {
  static Future<HttpResponseModel> createTransaction({
    required final String groupId,
    required final Transaction transaction,
  }) async {
    final result = await ApiInterface.postRequest(
        url:
            "createtransaction/${ClientProvider.readOnlyClient!.userId}/$groupId",
        data: {
          "typeOftransaction":
              transaction.transactionCategory.name.toLowerCase(),
          // "role":"Seller",
          "transactionName": transaction.transactionName,
          "aboutService": transaction.transactionDetail,
          "location": ClientProvider.readOnlyClient!.address,
          "inspectionPeriod": transaction.inspectionPeriod.name.toLowerCase(),
          "inspectionDays": transaction.inspectionDays,
          "DateOfWork": transaction.transactionTime.toIso8601String(),
        });

    return result;
  }

  static Future<HttpResponseModel> createPricing({
    required final String transactionId,
    required final String groupId,
    required final String buyerId,
    required final Product product,
  }) async {
    final file = await MultipartFile.fromPath(
        "pricingImage", product.productImages[0].toString(),
        filename: Path.basename(product.productImages[0].toString()),
        contentType: MediaType('image', "jpeg"));

    final result = await ApiInterface.multipartPostRequest(
        url:
            "createpricing/${ClientProvider.readOnlyClient!.userId}/$groupId/$transactionId/$buyerId",
        multiparts: [
          const MultiPartModel.field(field: "category", value: "No Category"),
          MultiPartModel.field(
              field: "productName", value: product.productName),
          MultiPartModel.field(
              field: "productCondition",
              value: product.productCondition.name.toLowerCase()),
          MultiPartModel.field(
              field: "quantity", value: product.quantity.toString()),
          MultiPartModel.field(field: "price", value: product.productPrice.toString()),
          MultiPartModel.file(file: file),
        ]);
    return result;
  }

  static Future<HttpResponseModel> getOneTransaction({
    required final String transactionId,
  }) async {
    final response = await ApiInterface.getRequest(
      url: "getOneTransaction/$transactionId",
    );

    return response;
  }

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
    final transactionsJson = result.messageBody!["data"]["transactions"];

    return HttpResponseModel(
        returnHeaderType: result.returnHeaderType,
        error: false,
        body: json.encode(transactionsJson),
        code: result.code);
  }

  Future<List<Transaction>> getTransactions() async{
    final response = await getAllTransactions();

    if(response.error){
      log("error fetching transactions from provider");
      return AppStorage.getTransactions();
    }
    else{
      final transactionsList = (json.decode(response.body) as List).map((e) => Transaction.fromJson(json: e)).toList();
      return transactionsList;
    }
  }
}
