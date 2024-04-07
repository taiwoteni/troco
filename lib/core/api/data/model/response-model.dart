import 'dart:convert';

class HttpResponseModel {
  final bool error;
  final String body;
  final int code;
  const HttpResponseModel(
      {required this.error, required this.body, required this.code});

  Map<dynamic,dynamic>? get messageBody => json.decode(body);

  Map<String,dynamic> decodeLoginData(){
    final loginData = messageBody!["data"];
    return {
      "id":loginData["_id"],
      "first name":loginData["first name"],
      "last name":loginData["last name"],
      "email":loginData["email"],
      "password":loginData["password"],
      "phone number":loginData["phoneNumber"],
      "state":loginData["state"],
      "city":loginData["city"],
      "profile":loginData["profile"],
      "zipcode":loginData["zipcode"],
      "address":loginData["address"],
      "nearest bustop":loginData["nearestBustop"],
      "business name":loginData["bussinessName"],
      "category":loginData["category"],
      "transaction pin":loginData["transactionPin"]
    };
  }
}
