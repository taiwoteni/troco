import 'dart:convert';
import 'dart:developer';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

import '../../../../core/api/data/model/response-model.dart';
import '../entity/bank.dart';

class BankRepository {
  static final bearerToken = dotenv.env["FLUTTERWAVE_TOKEN"] ?? '';
  static final flutterWaveApi = dotenv.env["FLUTTERWAVE_API_URL"] ?? '';
  static final nigerianBanksUrl = dotenv.env['NIGERIAN_BANKS_URL'] ?? '';

  static Future<HttpResponseModel> getAllBanks() async {
    final Uri uri = Uri.parse("${flutterWaveApi}/banks/NG");
    try {
      final request = http.Request('GET', uri);
      request.headers['Content-Type'] = 'application/json';

      /// Authorization Token needs to be gotten and placed here.
      request.headers["Authorization"] = "Bearer ${bearerToken}";
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
    final Uri uri = Uri.parse(nigerianBanksUrl + "/");
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
    final Uri uri = Uri.parse("${flutterWaveApi}/accounts/resolve");
    try {
      final request = http.Request('POST', uri);
      request.headers['Content-Type'] = 'application/json';

      /// Authorization Token needs to be gotten and placed here.
      request.headers["Authorization"] = "Bearer ${bearerToken}";
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
