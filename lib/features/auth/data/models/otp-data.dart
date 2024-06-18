import '../../../../core/api/data/model/response-model.dart';
import 'login-data.dart';

/// The id is only there for testing without @Finbar's ApIs
/// Once API is given, You should remove it.

class OtpData {
  static String? id,phoneNumber,
      email,
      password;
  static HttpResponseModel? model;    

  static void clear() {
    id = null;
    phoneNumber = null;
    email = null;
    password = null;
    model = null;
  }

  static bool isVerifying(){
    return phoneNumber == LoginData.phoneNumber && email == LoginData.email && password == LoginData.password; 
  }
}
