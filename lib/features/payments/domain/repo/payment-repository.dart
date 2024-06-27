
import 'package:troco/core/api/data/repositories/api-interface.dart';
import 'package:troco/features/auth/presentation/providers/client-provider.dart';
import 'package:troco/features/payments/domain/entity/card-method.dart';

import '../../../../core/api/data/model/response-model.dart';
import '../../../groups/domain/entities/group.dart';
import '../../../transactions/domain/entities/transaction.dart';

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
}