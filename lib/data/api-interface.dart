import 'dart:developer';

import 'package:http/http.dart' as http;
import 'package:troco/models/response-model.dart';

class ApiInterface {
  static const _serverUrl = "https://trocco-app-be-3.onrender.com/api/v1/";

  static Future<HttpResponseModel?> getRequest(
      {required final String url,
      final int okCode = 200,
      Map<String, String>? headers}) async {
    try {
      final response = await http.get(Uri.parse(url), headers: headers);
      final responseModel = HttpResponseModel(
        error: response.statusCode != okCode,
        body: response.body,
        code: response.statusCode);
        return responseModel;
    } catch (e) {
      log(e.toString());
      return null;
    }
  }

  static Future<HttpResponseModel?> postRequest(
      {required final String url,
      final int okCode = 200,
      required final Map<String, String> data,
      Map<String, String>? headers}) async {
    try {
      final response = await http.post(Uri.parse(url),
          body: data,
          headers:headers /**?? {'Content-Type': 'application/x-www-form-urlencoded'}*/);
      final responseModel = HttpResponseModel(
        error: response.statusCode != okCode,
        body: response.body,
        code: response.statusCode);
        return responseModel;
    } catch (e) {
      log(e.toString());
      return null;
    }
  }

  static Future<HttpResponseModel?> loginUserEmail(
      {required final String email,
      required final String password,
      final Map<String, String>? header}) async {
    final result = await postRequest(
        url: "$_serverUrl/loginuser",
        data: {"email": email, "password": password});
    return result;
  }

  static Future<HttpResponseModel?> loginUserPhone(
      {required final String email,
      required final String password,
      final Map<String, String>? header}) async {
    final result = await postRequest(
        url: "$_serverUrl/loginuser",
        data: {"phoneNumber": email, "password": password});
    return result;
  }

  static Future<HttpResponseModel?> patchRequest(
      {required final String url,
      final int okCode = 200,
      required final Map<String, String> data,
      Map<String, String>? headers}) async {
    try {
      final response =
          await http.patch(Uri.parse(url), body: data, headers: headers);
      final responseModel = HttpResponseModel(
        error: response.statusCode != okCode,
        body: response.body,
        code: response.statusCode);
        return responseModel;
    } catch (e) {
      log(e.toString());
      return null;
    }
  }

  static Future<HttpResponseModel?> registerUser(
      {required final String email,
      required final String phoneNumber,
      required final String password,
      Map<String, String>? headers}) async {
    final result = await postRequest(
        url: "${_serverUrl}createUser",
        okCode: 201,
        data: {
          'phoneNumber': phoneNumber,
          'password': password,
          'email': email,
        },
        headers: headers);
    return result;
  }

  static Future<HttpResponseModel?> verifyOTP(
      {required final String userId,
      required final String otp,
      required final Map<String, String>? headers}) async {
    final result =
        await postRequest(url: "$_serverUrl/verifyotp/$userId", data: {
      "otp": otp,
    });
    return result;
  }

  static Future<HttpResponseModel?> searchUser({
    required final String query,
    final Map<String, String>? headers,
  }) async {
    final result =
        await getRequest(url: '$_serverUrl/searchUser', headers: headers);
    return result;
  }

  static Future<HttpResponseModel?> findUser({
    required final String userId,
    final Map<String, String>? headers,
  }) async {
    final result = await getRequest(
        url: '$_serverUrl/findoneuser/$userId', headers: headers);
    return result;
  }

  static Future<HttpResponseModel?> updateUser({
    required final String userId,
    required final Map<String, String> body,
    final Map<String, String>? header,
  }) async {
    final result = await patchRequest(
        url: "$_serverUrl/updateuser/$userId", data: body, headers: header);
    return result;
  }
}
