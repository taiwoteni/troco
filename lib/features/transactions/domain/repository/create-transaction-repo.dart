// ignore_for_file: depend_on_referenced_packages
// ignore_for_file: implementation_imports

import 'package:http/http.dart';
import 'package:http_parser/src/media_type.dart';
import 'package:troco/core/api/data/model/multi-part-model.dart';
import 'package:troco/core/api/data/repositories/api-interface.dart';
import 'package:troco/features/auth/presentation/providers/client-provider.dart';
import 'package:troco/features/transactions/domain/entities/product.dart';
import 'package:troco/features/transactions/domain/entities/transaction.dart';

import '../../../../core/api/data/model/response-model.dart';

class CreateTransactionRepo {
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
    final result = await ApiInterface.multipartPostRequest(
        url: "createpricing/${ClientProvider.readOnlyClient!.userId}/$groupId/$transactionId/$buyerId",
        multiparts: [
          const MultiPartModel.field(field: "category", value: "No Category"),
          MultiPartModel.field(
              field: "productName", value: product.productName),
          MultiPartModel.field(
              field: "productCondition",
              value: product.productCondition.name.toLowerCase()),
          MultiPartModel.field(field: "quantity", value: product.quantity),
          MultiPartModel.field(field: "price", value: product.productPrice),
          MultiPartModel.file(
              file: MultipartFile.fromPath(
                  "pricingImage", product.productImages[0],
                  contentType: MediaType('image', "jpeg")))
        ]);
    return result;
  }
}
