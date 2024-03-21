import 'enums.dart';

class LoginData{
  static String? phoneNumber,email,password,nearestBustop;
  static String? firstName,lastName,address,businessName,city,state,zipCode;
  static Category? category;
  static int? long,lat;

  static void clear(){
    phoneNumber = null;
    email = null;
    password = null;
    firstName = null;
    lastName = null;
    nearestBustop = null;
    address = null;
    businessName = null;
    city = null;
    state = null;
    zipCode = null;
    category = null;
    long = null;
    lat = null;
  }
  
}