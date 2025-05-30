import 'dart:convert';

class HttpResponseModel {
  final bool error;
  final String body;
  final String returnHeaderType;
  final int code;
  const HttpResponseModel(
      {required this.error,
      this.returnHeaderType = "application/json",
      required this.body,
      required this.code});

  Map<dynamic, dynamic>? get messageBody {
    try {
      return json.decode(body);
    } on FormatException {
      return {};
    }
  }

  List<dynamic>? get messageListBody {
    try {
      return json.decode(body);
    } on FormatException {
      return [];
    }
  }

  Map<String, dynamic> decodeLoginData() {
    final loginData = messageBody!["data"];
    return {
      "id": loginData["_id"],
      "first name": loginData["first name"],
      "last name": loginData["last name"],
      "email": loginData["email"],
      "password": loginData["password"],
      "phone number": loginData["phoneNumber"],
      "state": loginData["state"],
      "city": loginData["city"],
      "profile": loginData["profile"],
      "zipcode": loginData["zipcode"],
      "address": loginData["address"],
      "nearest bustop": loginData["nearestBustop"],
      "business name": loginData["bussinessName"],
      "category": loginData["category"],
      "transaction pin": loginData["transactionPin"]
    };
  }
}
