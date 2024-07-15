
import 'dart:io';

import 'package:http/http.dart';
import 'package:troco/core/api/data/repositories/api-interface.dart';
import 'package:troco/features/auth/presentation/providers/client-provider.dart';
import 'package:path/path.dart' as Path;
import 'package:troco/features/payments/domain/entity/card-method.dart';

import '../../../../core/api/data/model/multi-part-model.dart';
import '../../../../core/api/data/model/response-model.dart';
import '../../../groups/domain/entities/group.dart';
import '../../../transactions/domain/entities/transaction.dart';
import '../entity/account-method.dart';

class PaymentRepository{

  static Future<HttpResponseModel> makeCardPayment({
    required final Transaction transaction,
    required final Group group,
    required final CardMethod card,
  })async{

    final result = await ApiInterface.postRequest(
      url: "makecardpayment/${ClientProvider.readOnlyClient!.userId}/${transaction.transactionId}/${group.adminId}/${group.groupId}",
      data: {
        "cardNumber":card.cardNumber,
        "expiry":card.expDate,
        "cvv":card.cvv
      });

    return result;
  }
  static Future<HttpResponseModel> uploadSelectedAccount({
    required final Group group,
    required final AccountMethod account
  })async{

    final response = await ApiInterface.postRequest(
      url: "uploadaccountdetails/${ClientProvider.readOnlyClient!.userId}/${group.groupId}",
      data: {
        "accountName":account.accountName,
        "accountNumber":account.accountNumber,
        "bankName":account.bank.name,
      });

    return response;
  }

  static Future<HttpResponseModel> uploadReceipt({
    required final Transaction transaction,
    required final String path
  })async{

    final multiparts = <MultiPartModel>[];

    var parsedfile = File(path);
    var stream = ByteStream(parsedfile.openRead());
    var length = await parsedfile.length();
    final file = MultipartFile(
      "paymentReceipt",
      stream,
      length,
      filename: Path.basename(path.toString()));

    multiparts.add(MultiPartModel.file(file: file));


    final response = await ApiInterface.multipartPostRequest(
      url: "uploadreceipt/${ClientProvider.readOnlyClient!.userId}/${transaction.transactionId}",
      multiparts: multiparts);


    return response;

  }
}