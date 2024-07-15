// ignore_for_file: unnecessary_string_interpolations
import 'dart:convert';
import 'dart:developer';
import 'package:http/http.dart' as http;
import 'package:troco/core/api/data/model/multi-part-model.dart';
import 'package:troco/core/api/data/model/response-model.dart';

class ApiInterface {
  static const _serverUrl = "https://trocco-app-be-3-oou2.onrender.com/api/v1";

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
      if (headers != null) {
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
          returnHeaderType: response.headers["content-type"]!,
          error: response.statusCode != okCode,
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
      if (headers != null) {
        headers.forEach((key, value) {
          request.headers[key] = value;
        });
      }
      request.body = jsonData;
      final response = await http.Client().send(request);

      final String body = await response.stream.bytesToString();
      final responseModel = HttpResponseModel(
          returnHeaderType: response.headers["content-type"]!,
          error: response.statusCode != okCode,
          body: body,
          code: response.statusCode);
      return responseModel;
    } catch (e) {
      log("error caught in runtimer exception $e");
      return HttpResponseModel(
          error: true,
          body: json.encode({"message": "An unknown exception occured"}),
          code: 500);
    }
  }

  static Future<HttpResponseModel> patchRequest(
      {required final String url,
      final int okCode = 200,
      required final dynamic data,
      Map<String, String>? headers}) async {
    try {
      final Uri uri = Uri.parse("$_serverUrl/$url");
      final jsonData = data == null ? null : json.encode(data);
      final request = http.Request('PATCH', uri);
      request.headers['Content-Type'] = 'application/json';
      request.headers['accept'] = '*/*';
      if (headers != null) {
        headers.forEach((key, value) {
          request.headers[key] = value;
        });
      }
      if (jsonData != null) {
        request.body = jsonData;
      }
      final response = await http.Client().send(request);

      final String body = await response.stream.bytesToString();
      final responseModel = HttpResponseModel(
          returnHeaderType: response.headers["content-type"]!,
          error: response.statusCode != okCode,
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

  static Future<HttpResponseModel> multipartPatchRequest(
      {required final String url,
      final int okCode = 200,
      required final List<MultiPartModel> multiparts,
      Map<String, String>? headers}) async {
    try {
      final Uri uri = Uri.parse("$_serverUrl/$url");
      final request = http.MultipartRequest('PATCH', uri);
      request.headers['Content-Type'] = 'multipart/form-data';
      request.headers['accept'] = '*/*';
      if (headers != null) {
        headers.forEach((key, value) {
          request.headers[key] = value;
        });
      }

      for (final model in multiparts) {
        if (model.isFileType) {
          request.files.add(await model.file!);
        } else {
          if (model.value != null) {
            final value = model.value!.toString();
            request.fields[model.field!.toString()] = value;
            // log("added field : ${model.field!}: ${model.value}");
          }
        }
      }

      final response = await request.send();

      final String body = await response.stream.bytesToString();
      final responseModel = HttpResponseModel(
          returnHeaderType: response.headers["content-type"]!,
          error: response.statusCode != okCode,
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

  static Future<HttpResponseModel> multipartPostRequest(
      {required final String url,
      final int okCode = 200,
      required final List<MultiPartModel> multiparts,
      Map<String, String>? headers}) async {
    try {
      final Uri uri = Uri.parse("$_serverUrl/$url");
      final request = http.MultipartRequest('POST', uri);
      request.headers['Content-Type'] = 'multipart/form-data';

      request.headers['accept'] = '*/*';
      // if (headers != null) {
      //   headers.forEach((key, value) {
      //     request.headers[key] = value;
      //   });
      // }

      for (int i = 0; i < multiparts.length; i++) {
        final model = multiparts[i];
        if (!model.isFileType) {
          if (model.value != null) {
            final value = model.value!.toString();
            request.fields[model.field!.toString()] = value;
            // log("added field : ${model.field!}: ${model.value}");
          }
        } else {
          request.files.add(model.file!);
          // log("added file: ${model.file!.field}: ${model.file!.filename}");
        }
      }

      // log(request.fields.toString());
      // log(request.files.map((e) => {"${e.field}": e.filename}).toString());

      final response = await request.send();
      // log("sent");

      final String body = await response.stream.bytesToString();
      final responseModel = HttpResponseModel(
          // returnHeaderType: response.headers["content-type"],
          error: response.statusCode != okCode,
          body: body,
          code: response.statusCode);
      return responseModel;
    } catch (e) {
      // log(e.toString());
      return HttpResponseModel(
          error: true, body: json.encode({"message": "$e"}), code: 500);
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
          returnHeaderType: response.headers["content-type"]!,
          error: response.statusCode != okCode,
          body: body,
          code: response.statusCode);
      return responseModel;
    } catch (e) {
      return HttpResponseModel(
          error: true,
          body: json.encode({"message": "An unknown exception occured"}),
          code: 500);
    }
  }

  static Future<HttpResponseModel> searchUser({
    required final String query,
    final Map<String, String>? headers,
  }) async {
    final result = await postRequest(
        url: 'searchUser', data: {"query": query}, headers: headers);
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
