import 'package:troco/core/api/data/repositories/api-interface.dart';
import 'package:troco/features/auth/presentation/providers/client-provider.dart';
import 'package:troco/features/transactions/domain/entities/transaction.dart';

import '../../../../core/api/data/model/response-model.dart';

class CreateTransactionRepo{

 static Future<HttpResponseModel> createTransaction({
  required final String userId,
  required final String groupId,
  required final Transaction transaction,
 })async{

  final result = await ApiInterface.postRequest(
    url: "createtransaction/$userId/$groupId", 
    data: {
      "typeOfTransaction":transaction.transactionCategory.name.toLowerCase(),
      "role":"Seller",
      "transactionName":transaction.transactionName,
      "aboutService":transaction.transactionDetail,
      "location":ClientProvider.readOnlyClient!.address,
      "inspectionPeriod":"",
      "inspectionDays":"",
      "DateOfWork":"",
    });
  
  return result;

 }

}