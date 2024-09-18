import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:troco/core/api/data/repositories/api-interface.dart';
import 'package:troco/core/cache/shared-preferences.dart';
import 'package:troco/features/auth/presentation/providers/client-provider.dart';
import 'package:troco/features/payments/domain/entity/account-method.dart';
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
    final clientJson = AppStorage.getUser()!.toJson();
    final userReferrals = clientJson["referrals"] as List;

    final List<Referral> referrals = [];

    for (final String referral in userReferrals) {
      final response = await ApiInterface.findUser(userId: referral);
      if (!response.error) {
        final userJson = response.messageBody!["data"] as Map<dynamic, dynamic>;

        final transactionsList = userJson["transactions"] as List;

        final bool referralCompleted = !transactionsList.every((element) =>
            element["status"].toString().toLowerCase() != "completed");

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

  static Future<HttpResponseModel> getUserReferrals(
      {required final String userId}) async {
    final response = await ApiInterface.findUser(userId: userId);
    if (response.error) {
      return response;
    }
    final clientJson = response.messageBody?["data"] ?? {};
    final userReferrals = clientJson["referrals"] as List;

    final List<Map> referrals = [];

    for (final String referral in userReferrals) {
      final response = await ApiInterface.findUser(userId: referral);
      if (!response.error) {
        final userJson = response.messageBody!["data"] as Map<dynamic, dynamic>;

        final transactionsList = userJson["transactions"] as List;

        final bool referralCompleted = !transactionsList.every((element) =>
            element["status"].toString().toLowerCase() != "completed");

        final referralJson = {};
        referralJson["referralStatus"] =
            referralCompleted ? "completed" : "pending";
        // To remove bulky data
        userJson.remove("transactions");
        userJson.remove("groups");
        referralJson["userJson"] = userJson;

        final referral = Referral.fromJson(json: referralJson);
        referrals.add(referralJson);
      }
    }

    return HttpResponseModel(
        error: false,
        body: jsonEncode({"message": "Got referrals", "data": referrals}),
        code: response.code);
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
