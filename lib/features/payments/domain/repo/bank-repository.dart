import 'dart:convert';
import 'dart:developer';

import 'package:http/http.dart' as http;

import '../../../../core/api/data/model/response-model.dart';
import '../entity/bank.dart';

const bearerToken =
    "Bearer FLWSECK-89b17dd7e4587c4b72e05c9e69fbcfa1-19035d07801vt-X";

class BankRepository {
  static Future<HttpResponseModel> getAllBanks() async {
    final Uri uri = Uri.parse("https://api.flutterwave.com/v3/banks/NG");
    try {
      final request = http.Request('GET', uri);
      request.headers['Content-Type'] = 'application/json';

      /// Authorization Token needs to be gotten and placed here.
      request.headers["Authorization"] = bearerToken;
      final response = await http.Client().send(request);

      final String body = await response.stream.bytesToString();
      final responseModel = HttpResponseModel(
          returnHeaderType: response.headers["content-type"]!,
          error: response.statusCode != 200,
          body: body,
          code: response.statusCode);
      return responseModel;
    } catch (e) {
      log(e.toString());
      return HttpResponseModel(
          error: true,
          body: json.encode({"message": "An unknown exception occured"}),
          code: 500);
    }
  }

  static Future<HttpResponseModel> getAllBanksWithLogo() async {
    final Uri uri = Uri.parse("https://nigerianbanks.xyz/");
    try {
      final request = http.Request('GET', uri);
      request.headers['Content-Type'] = 'application/json';
      final response = await http.Client().send(request);

      final String body = await response.stream.bytesToString();
      final responseModel = HttpResponseModel(
          returnHeaderType: response.headers["content-type"]!,
          error: response.statusCode != 200,
          body: body,
          code: response.statusCode);
      return responseModel;
    } catch (e) {
      log(e.toString());
      return HttpResponseModel(
          error: true,
          body: json.encode({"message": "An unknown exception occured"}),
          code: 500);
    }
  }

  static Future<HttpResponseModel> verifyBankAccount({
    required final String accountNo,
    required final Bank bank,
  }) async {
    final Uri uri =
        Uri.parse("https://api.flutterwave.com/v3/accounts/resolve");
    try {
      final request = http.Request('POST', uri);
      request.headers['Content-Type'] = 'application/json';

      /// Authorization Token needs to be gotten and placed here.
      request.headers["Authorization"] = bearerToken;
      request.body =
          json.encode({"account_number": accountNo, "account_bank": bank.code});
      log(request.body);
      final response = await http.Client().send(request);

      final String body = await response.stream.bytesToString();
      final responseModel = HttpResponseModel(
          returnHeaderType: response.headers["content-type"]!,
          error: response.statusCode != 200,
          body: body,
          code: response.statusCode);
      return responseModel;
    } catch (e) {
      log(e.toString());
      return HttpResponseModel(
          error: true,
          body: json.encode({"message": "An unknown exception occured"}),
          code: 500);
    }
  }
}
