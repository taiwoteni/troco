import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:troco/core/api/data/repositories/api-interface.dart';
import 'package:troco/core/cache/shared-preferences.dart';
import 'package:troco/features/auth/presentation/providers/client-provider.dart';
import 'package:troco/features/payments/domain/entity/account-method.dart';
import 'package:troco/features/transactions/domain/entities/transaction.dart';
import 'package:troco/features/transactions/utils/enums.dart';
import 'package:troco/features/wallet/domain/entities/referral.dart';
import 'package:troco/features/wallet/domain/entities/wallet-transaction.dart';

import '../../../../core/api/data/model/response-model.dart';

class WalletRepository {
  static Future<HttpResponseModel> requestWithdrawal({
    required final double amount,
    required final AccountMethod account,
  }) async {
    final result = await ApiInterface.postRequest(
        url: "requestwithdrawal/${ClientProvider.readOnlyClient!.userId}",
        okCode: 201,
        data: {
          "amount": amount,
          "accountName": account.accountName,
          "accountNumber": account.accountNumber,
          "bankName": account.bank.name,
        });

    return result;
  }

  Future<List<Referral>> getReferrals() async {
    final response = await ApiInterface.getRequest(
      url: 'getreferred_users/${ClientProvider.readOnlyClient!.userId}',
    );
    if (response.error) {
      return AppStorage.getReferrals();
    }

    return ((response.messageBody?["data"] ?? []) as List)
        .map(
          (e) => Referral.fromJson(json: e),
        )
        .toList();
  }

  static Future<HttpResponseModel> referPhoneNumber(
      {required final String phoneNumber}) {
    return ApiInterface.postRequest(
        url: "send_referral_message/${ClientProvider.readOnlyClient?.userId}",
        data: {"phoneNumber": phoneNumber});
  }

  static Future<HttpResponseModel> getUserReferrals(
      {required final String userId}) async {
    return await ApiInterface.getRequest(
      url: 'getreferred_users/$userId',
    );
  }

  Future<List<WalletTransaction>> getWalletHistory() async {
    final request = await ApiInterface.getRequest(
        url: "getwallethistory/${ClientProvider.readOnlyClient!.userId}",
        data: null);

    debugPrint(request.body);

    if (request.error) {
      return AppStorage.getWalletTransactions();
    }

    return (request.messageBody!["data"] as List)
        .map(
          (e) => WalletTransaction.fromJson(json: e),
        )
        .toList();
  }
}
