import 'package:troco/core/cache/shared-preferences.dart';
import 'package:troco/features/auth/presentation/providers/client-provider.dart';
import 'package:troco/features/settings/utils/enums.dart';

import '../../../../core/api/data/model/response-model.dart';
import '../../../../core/api/data/repositories/api-interface.dart';

class SettingsRepository {
  static Future<HttpResponseModel> updatePassword({
    required final String userId,
    required final String oldPassword,
    required final String newPassword,
  }) async {
    final request = await ApiInterface.patchRequest(
        url: "updatepassword/$userId",
        data: {"oldpassword": oldPassword, "newpassword": newPassword});

    return request;
  }

  static Future<HttpResponseModel> changeEmail(
      {required String newEmail}) async {
    final json = AppStorage.getUser()!.toJson();
    json["email"] = newEmail;
    final response = await ApiInterface.patchRequest(
        url: "updateusersetting/${ClientProvider.readOnlyClient!.userId}",
        data: json);

    return response;
  }

  static Future<HttpResponseModel> changePhoneNumber(
      {required String newPhoneNumber}) async {
    final json = AppStorage.getUser()!.toJson();
    json["phoneNumber"] = newPhoneNumber;
    final response = await ApiInterface.patchRequest(
        url: "updateusersetting/${ClientProvider.readOnlyClient!.userId}",
        data: json);

    return response;
  }

  static Future<HttpResponseModel> updateTransactionPin({
    required final String userId,
    required final String oldPin,
    required final String newPin,
  }) async {
    final request = await ApiInterface.patchRequest(
        url: "changetransactionpin/$userId",
        data: {"oldtransactPin": oldPin, "newtransactPin": newPin});

    return request;
  }

  static Future<HttpResponseModel> setTwoFactorMethod(
      {required final String userId,
      required final TwoFactorMethod method}) async {
    final request =
        await ApiInterface.patchRequest(url: "settwofactorauth/$userId", data: {
      "twofactorType": method == TwoFactorMethod.Otp ? "Otp" : "Transaction Pin"
    });

    return request;
  }

  static Future<HttpResponseModel> disableTwoFactor(
      {required final String userId}) async {
    final request = await ApiInterface.patchRequest(
        url: "disabletwofactorauth/$userId", data: null);

    return request;
  }

  static Future<HttpResponseModel> requestPasswordReset(
      {required final String emailOrPhone}) async {
    final request = await ApiInterface.postRequest(
        url: "requestpasswordreset", data: {"emailOrPhone": emailOrPhone});

    return request;
  }

  static Future<HttpResponseModel> verifyPasswordResetOtp(
      {required final String emailOrPhone, required final String otp}) async {
    final request = await ApiInterface.postRequest(
        url: "verifypasswordresetotp",
        data: {"emailOrPhone": emailOrPhone, "otp": otp});

    return request;
  }

  static Future<HttpResponseModel> resetPassword(
      {required final String emailOrPhone,
      required final String newPassword}) async {
    final request = await ApiInterface.postRequest(
        url: "resetPassword",
        data: {"emailOrPhone": emailOrPhone, "newPassword": newPassword});

    return request;
  }

  static Future<HttpResponseModel> requestPinReset(
      {required final String? email,
      required final String? phoneNumber}) async {
    final request = await ApiInterface.postRequest(
        url: "requestpinreset",
        data: {"email": email, "phoneNumber": phoneNumber});

    return request;
  }

  static Future<HttpResponseModel> verifyPinResetOtp(
      {required final String? email,
      required final String? phoneNumber,
      required final String otp}) async {
    final request = await ApiInterface.postRequest(
        url: "verifypinresetotp",
        data: {"email": email, "phoneNumber": phoneNumber, "otp": otp});

    return request;
  }

  static Future<HttpResponseModel> resetPin(
      {required final String? email,
      required final String? phoneNumber,
      required final String newPin}) async {
    final request = await ApiInterface.postRequest(
        url: "resetPin",
        data: {"email": email, "phoneNumber": phoneNumber, "newPin": newPin});

    return request;
  }
}
