import 'package:troco/core/api/data/repositories/api-interface.dart';
import 'package:troco/features/auth/presentation/providers/client-provider.dart';
import 'package:troco/features/payments/domain/entity/account-method.dart';

import '../../../../core/api/data/model/response-model.dart';

class WalletRepository {
  static Future<HttpResponseModel> requestWithdrawal({
    required final double amount,
    required final AccountMethod account,
  }) async {
    final result = await ApiInterface.postRequest(
        url: "requestwithdrawal/${ClientProvider.readOnlyClient!.userId}",
        data: {
          "amount":amount,
          "accountName":account.accountName,
          "accountNumber":account.accountNumber,
          "bankName":account.bank.name,
        });

    return result;
  }
}
