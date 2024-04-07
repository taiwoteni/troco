import 'package:flutter/cupertino.dart';
import 'package:troco/core/app/asset-manager.dart';
import '../../../transactions/utils/enums.dart';
import '../../utils/category-converter.dart';

class Client{
  Map<dynamic,dynamic> _json;
  Client.fromJson({required final Map<dynamic,dynamic> json}):_json = json;


  String get userId => _json["id"] ?? "7832u8923";
  String get firstName => _json["first name"];
  String get lastName => _json["last name"];
  String get profile => _json["profile"]??"null";
  String get fullName => "$firstName $lastName";
  String get email => _json["email"]; 
  String get phoneNumber => _json["phone number"];
  String get businessName => _json["business name"];
  Category get accountCategory => CatgoryConverter.convertToCategory(category: _json["category"]); 
  String get address => _json["address"];
  String get city => _json["city"];
  String get state => _json["state"];
  String get zipcode => _json["zipcode"];
  String get bustop => _json["nearest bustop"];
  String get transactionPin => _json["transaction pin"];

  ImageProvider<Object> profileImage(){
    if(_json["profile"] == null){
      return AssetImage(AssetManager.imageFile(name: "profile_img"));
    }
    return NetworkImage(_json["profile"]);
  }

  Map<dynamic,dynamic> toJson(){
    return _json;
  }

}