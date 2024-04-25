// ignore_for_file: depend_on_referenced_packages
// ignore_for_file: implementation_imports

import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import "package:path/path.dart" as Path;
import 'package:http/http.dart';
import 'package:troco/core/api/data/model/multi-part-model.dart';
import 'package:troco/core/api/data/repositories/api-interface.dart';
import 'package:troco/core/cache/shared-preferences.dart';
import 'package:troco/features/auth/presentation/providers/client-provider.dart';
import 'package:troco/features/transactions/domain/entities/product.dart';
import 'package:troco/features/transactions/domain/entities/transaction.dart';
import 'package:troco/features/transactions/utils/enums.dart';

import '../../../../core/api/data/model/response-model.dart';

class TransactionRepo {
  static Future<HttpResponseModel> createTransaction(
      {required final String groupId,
      required final Transaction transaction,
      required final String dateOfWork}) async {
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
          "DateOfWork": dateOfWork,
        });

    return result;
  }

  static Future<HttpResponseModel> createPricing({
    required final String transactionId,
    required final String groupId,
    required final String buyerId,
    required final Product product,
  }) async {
    var parsedfile = File(product.productImages[0]);
    var stream = ByteStream(parsedfile.openRead());
    var length = await parsedfile.length();

    final file = MultipartFile("pricingImage", stream, length,
        filename: Path.basename(product.productImages[0].toString()));

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
          MultiPartModel.field(field: "quantity", value: product.quantity),
          MultiPartModel.field(field: "price", value: product.productPrice),
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

    final transactionsJson = result.messageBody!["data"]["transactions"];

    final List<String> transactionsId = (transactionsJson as List).map((e) => e["_id"].toString()).toList();

    List<Map<dynamic,dynamic>> jsonData = [];
    for(final String id in transactionsId){
      final response = await getOneTransaction(transactionId: id);
      if(response.error){
        return HttpResponseModel(
          error: response.error, 
          body: response.body,
          code: response.code);
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
      log("error fetching transactions from provider");
      return AppStorage.getTransactions();
    } else {
      final transactionsList = (json.decode(response.body) as List)
          .map((e) => Transaction.fromJson(json: e))
          .toList();
      return transactionsList;
    }
  }


  Future<HttpResponseModel> respondToTransaction({
    required final bool aprove,
    required final Transaction transaction,
    required final TransactionStatus status,
    })async{
      final result = await ApiInterface.postRequest(
        url: "updateTransactionStatus/${transaction.transactionId}/${ClientProvider.readOnlyClient!.userId}/${transaction.creator}",
        data: {
          "status":aprove?"approved":"declined"
        });

      return result;
  }
}
