import '../../domain/entities/client.dart';
import '../../utils/category-converter.dart';
import '../../../transactions/utils/enums.dart';

/// The id is only there for testing without @Finbar's ApIs
/// Once API is given, You should remove it.

class LoginData {
  static String? phoneNumber,
      email,
      password,
      id,
      nearestBustop,
      transactionPin;
  static String? firstName,
      profile,
      lastName,
      address,
      businessName,
      otp,
      city,
      state,
      zipCode;
  static Category? category;
  static int? long, lat;

  static void clear() {
    id = null;
    phoneNumber = null;
    email = null;
    password = null;
    firstName = null;
    lastName = null;
    transactionPin = null;
    nearestBustop = null;
    address = null;
    businessName = null;
    city = null;
    state = null;
    zipCode = null;
    category = null;
    profile = null;
    long = null;
    lat = null;
  }

  static Map<String, dynamic> toClientJson() {
    return {
      "id": id,
      "firstName": firstName,
      "lastName": lastName,
      "password":password,
      "email": email,
      "profile": profile,
      "phoneNumber": phoneNumber,
      "businessName": businessName,
      "accountType": CategoryConverter.convertToString(category: category!),
      "address": address,
      "city": city,
      "state": state,
      "nearestBustop": nearestBustop,
      "transactionPin": transactionPin,
      "zipcode": zipCode,
    };
  }

  static Client toClient() {
    return Client.fromJson(json: toClientJson());
  }
}
