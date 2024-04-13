// ignore_for_file: unnecessary_string_interpolations
import 'dart:convert';
import 'dart:developer';
import 'package:http/http.dart' as http;
import 'package:troco/core/api/data/model/response-model.dart';

class ApiInterface {
  static const _serverUrl = "https://trocco-app-be-3.onrender.com/api/v1/";

  static Future<HttpResponseModel> getRequest(
      {required final String url,
      final Map<String, dynamic>? data,
      final int okCode = 200,
      Map<String, String>? headers}) async {
    try {
      final Uri uri = Uri.parse("$_serverUrl/$url");

      final request = http.Request('GET', uri);
      request.headers['Content-Type'] = 'application/json';
      request.headers['accept'] = '*/*';
      if(headers != null){
        headers.forEach((key, value) {
          request.headers[key] = value;
        });
      }
      if (data != null) {
        request.body = json.encode(data);
      }
      final response = await http.Client().send(request);

      final String body = await response.stream.bytesToString();
      final responseModel = HttpResponseModel(
          error: response.statusCode != okCode,
          body: body,
          code: response.statusCode);
      return responseModel;
    } catch (e) {
      log(e.toString());
      return HttpResponseModel(error: true, body: e.toString(), code: 500);
    }
  }

  static Future<HttpResponseModel> postRequest(
      {required final String url,
      final int okCode = 200,
      required final Map<String, dynamic> data,
      Map<String, String>? headers}) async {
    try {
      final Uri uri = Uri.parse("$_serverUrl/$url");
      final jsonData = json.encode(data);
      final request = http.Request('POST', uri);
      request.headers['Content-Type'] = 'application/json';
      request.headers['accept'] = '*/*';
      if(headers != null){
        headers.forEach((key, value) {
          request.headers[key] = value;
        });
      }
      request.body = jsonData;
      final response = await http.Client().send(request);

      final String body = await response.stream.bytesToString();
      final responseModel = HttpResponseModel(
          error: response.statusCode != okCode,
          body: body,
          code: response.statusCode);
      return responseModel;
    } catch (e) {
      log("error caught in runtimer exception $e");
      return HttpResponseModel(error: true, body: e.toString(), code: 500);
    }
  }

  static Future<HttpResponseModel> patchRequest(
      {required final String url,
      final int okCode = 200,
      required final dynamic data,
      Map<String, String>? headers}) async {
    try {
      final Uri uri = Uri.parse("$_serverUrl/$url");
      final jsonData = json.encode(data);
      final request = http.Request('PATCH', uri);
      request.headers['Content-Type'] = 'application/json';
      request.headers['accept'] = '*/*';
      if(headers != null){
        headers.forEach((key, value) {
          request.headers[key] = value;
        });
      }
      request.body = jsonData;
      final response = await http.Client().send(request);

      final String body = await response.stream.bytesToString();
      final responseModel = HttpResponseModel(
          error: response.statusCode != okCode,
          body: body,
          code: response.statusCode);
      return responseModel;
    } catch (e) {
      log(e.toString());
      return HttpResponseModel(error: true, body: e.toString(), code: 500);
    }
  }

  static Future<HttpResponseModel> deleteRequest(
      {required final String url,
      final Map<String, String>? data,
      final int okCode = 200,
      Map<String, String>? headers}) async {
    try {
      final Uri uri = Uri.parse("$_serverUrl/$url");

      final request = http.Request('DELETE', uri);
      request.headers['Content-Type'] = 'application/json';
      request.headers['accept'] = '*/*';
      if (data != null) {
        request.body = json.encode(data);
      }
      final response = await http.Client().send(request);

      final String body = await response.stream.bytesToString();
      final responseModel = HttpResponseModel(
          error: response.statusCode != okCode,
          body: body,
          code: response.statusCode);
      return responseModel;
    } catch (e) {
      return HttpResponseModel(error: true, body: e.toString(), code: 500);
    }
  }

  static Future<HttpResponseModel> searchUser({
    required final String query,
    final Map<String, String>? headers,
  }) async {
    final result = await getRequest(url: 'searchUser', headers: headers);
    return result;
  }

  static Future<HttpResponseModel> findUser({
    required final String userId,
    final Map<String, String>? headers,
  }) async {
    final result =
        await getRequest(url: 'findoneuser/$userId', headers: headers);
    return result;
  }
}
