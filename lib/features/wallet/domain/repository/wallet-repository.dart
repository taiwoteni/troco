import 'package:troco/core/api/data/repositories/api-interface.dart';
import 'package:troco/core/cache/shared-preferences.dart';
import 'package:troco/features/auth/presentation/providers/client-provider.dart';
import 'package:troco/features/payments/domain/entity/account-method.dart';
import 'package:troco/features/wallet/domain/entities/referral.dart';

import '../../../../core/api/data/model/response-model.dart';

class WalletRepository {
  static Future<HttpResponseModel> requestWithdrawal({
    required final double amount,
    required final AccountMethod account,
  }) async {
    final result = await ApiInterface.postRequest(
        url: "requestwithdrawal/${ClientProvider.readOnlyClient!.userId}",
        data: {
          "amount": amount,
          "accountName": account.accountName,
          "accountNumber": account.accountNumber,
          "bankName": account.bank.name,
        });

    return result;
  }

  Future<List<Referral>> getReferrals() async {
    final clientJson = AppStorage.getUser()!.toJson();
    final userReferrals = clientJson["referrals"] as List<String>;

    final List<Referral> referrals = [];

    for (final String referral in userReferrals) {
      final response = await ApiInterface.findUser(userId: referral);
      if (!response.error) {
        final userJson = response.messageBody!["data"] as Map<dynamic, dynamic>;

        final transactionsList = userJson["transactions"] as List<Map>;

        final bool referralCompleted = !transactionsList
            .every((element) => element["status"] != "completed");

        final referralJson = {};
        referralJson["referralStatus"] =
            referralCompleted ? "completed" : "pending";
        // To remove bulky data
        userJson.remove("transactions");
        userJson.remove("groups");
        referralJson["userJson"] = userJson;

        final referral = Referral.fromJson(json: referralJson);
        referrals.add(referral);
      }
    }

    if (referrals.isEmpty) {
      return AppStorage.getReferrals();
    }

    return referrals;
  }
}
