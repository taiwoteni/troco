// ignore_for_file: depend_on_referenced_packages, library_prefixes

import 'package:http/http.dart';
import 'package:http_parser/http_parser.dart';
import "package:path/path.dart" as Path;
import 'package:troco/core/api/data/model/multi-part-model.dart';

import 'package:troco/core/api/data/repositories/api-interface.dart';

import '../../../../core/api/data/model/response-model.dart';

class AuthenticationRepo {
  static Future<HttpResponseModel> loginUserEmail(
      {required final String email,
      required final String password,
      final Map<String, String>? header}) async {
    final result = await ApiInterface.postRequest(
        url: "loginuser", data: {"email": email, "password": password});
    return result;
  }

  static Future<HttpResponseModel> loginUserPhone(
      {required final String phoneNumber,
      required final String password,
      final Map<String, String>? header}) async {
    final result = await ApiInterface.postRequest(
        url: "loginuser",
        data: {"phoneNumber": phoneNumber, "password": password});
    return result;
  }

  static Future<HttpResponseModel> registerUser(
      {required final String email,
      required final String phoneNumber,
      required final String password,
      Map<String, String>? headers}) async {
    final body = {
      "email": email,
      "password": password,
      'phoneNumber': phoneNumber,
    };
    final result = await ApiInterface.postRequest(
        url: "createUser", okCode: 200, data: body, headers: headers);
    return result;
  }

  static Future<HttpResponseModel> verifyOTP(
      {required final String userId,
      required final String otp,
      final Map<String, String>? headers}) async {
    final result =
        await ApiInterface.postRequest(url: "verifyotp/$userId", data: {
      "otp": int.parse(otp),
    });
    return result;
  }
  //66151e93e4d870dc1782e4b2

  static Future<HttpResponseModel> resendOTP(
      {required final String userId,
      required final String otp,
      final Map<String, String>? headers}) async {
    final result =
        await ApiInterface.postRequest(url: "resend-otp/$userId", data: {
      "otp": int.parse(otp),
    });
    return result;
  }

  static Future<HttpResponseModel> updateUser({
    required final String userId,
    required final Map<String, dynamic> body,
    final Map<String, String>? header,
  }) async {
    final result = await ApiInterface.patchRequest(
        url: "updateuser/$userId", data: body, headers: header);
    return result;
  }

  static Future<HttpResponseModel> addTransactionPin(
      {required final String userId,
      required final String pin,
      final Map<String, String>? headers}) async {
    final result = await ApiInterface.patchRequest(
        url: "addtransactionPin/$userId",
        data: {
          "transactionPin": pin,
        });
    return result;
  }

  static Future<HttpResponseModel> uploadProfilePhoto(
      {required final String userId, required final String profilePath}) async {

    final result = await ApiInterface.multipartPatchRequest(
        multiparts: [
          MultiPartModel.file(
              file: MultipartFile.fromPath("userImage", profilePath,
                  filename: Path.basename(profilePath),
                  contentType: MediaType('image', 'jpeg')))
        ],
        url: 'updateUserImage/$userId',
        headers: {"Content-Type": "multipart/form-data"});
    return result;
  }

  static Future<HttpResponseModel> deleteUser(
      {required final String userId}) async {
    final result = await ApiInterface.deleteRequest(url: "deleteuser/$userId");
    return result;
  }
}
