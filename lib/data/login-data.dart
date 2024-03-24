import '../models/client.dart';
import 'converters.dart';
import 'enums.dart';

class LoginData {
  static String? phoneNumber, email, password, nearestBustop, transactionPin;
  static String? firstName,
      profile,
      lastName,
      address,
      businessName,
      city,
      state,
      zipCode;
  static Category? category;
  static int? long, lat;

  static void clear() {
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

  static Map<dynamic, dynamic> toClientJson() {
    return {
      "first name": firstName,
      "last name": lastName,
      "email": email,
      "profile": profile,
      "phone number": phoneNumber,
      "business name": businessName,
      "category": CatgoryConverter.convertToString(category: category!),
      "address": address,
      "city": city,
      "state": state,
      "nearest bustop": nearestBustop,
      "transaction pin": transactionPin,
      "zipcode": zipCode,
    };
  }

  static Client toClient() {
    return Client.fromJson(json: toClientJson());
  }
}
