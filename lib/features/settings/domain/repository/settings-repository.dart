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
      {required final String email}) async {
    final request = await ApiInterface.postRequest(
        url: "requestpasswordreset", data: {"email": email});

    return request;
  }

  static Future<HttpResponseModel> verifyPasswordResetOtp(
      {required final String email,required final String otp}) async {
    final request = await ApiInterface.postRequest(
        url: "verifypasswordresetotp", data: {"email": email,"otp":otp});

    return request;
  }

  static Future<HttpResponseModel> resetPassword(
      {required final String email,required final String newPassword}) async {
    final request = await ApiInterface.postRequest(
        url: "resetPassword", data: {"email": email,"newPassword":newPassword});

    return request;
  }
}
