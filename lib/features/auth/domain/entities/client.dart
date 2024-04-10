import 'package:equatable/equatable.dart';
import 'package:flutter/cupertino.dart';
import 'package:troco/core/app/asset-manager.dart';
import '../../../transactions/utils/enums.dart';
import '../../utils/category-converter.dart';


class Client extends Equatable{
  final Map<dynamic,dynamic> _json;
  const Client.fromJson({required final Map<dynamic,dynamic> json}):_json = json;


  String get userId => _json["id"] ?? "7832u8923";
  String get firstName => _json["firstName"];
  String get lastName => _json["lastName"];
  String get profile => _json["profile"]??"null";
  String get fullName => "$firstName $lastName";
  String get email => _json["email"]; 
  String get phoneNumber => _json["phoneNumber"];
  String get businessName => _json["businessName"] ?? "$firstName Ventures";
  Category get accountCategory => CatgoryConverter.convertToCategory(category: _json["category"]??"merchant"); 
  String get address => _json["address"];
  String get city => _json["city"];
  String get state => _json["state"];
  String get zipcode => _json["zipcode"];
  String get bustop => _json["nearestBustop"];
  String get transactionPin => _json["transactionPin"];

  ImageProvider<Object> profileImage(){
    if(_json["profile"] == null){
      return AssetImage(AssetManager.imageFile(name: "profile_img"));
    }
    return NetworkImage(_json["profile"]);
  }

  Map<dynamic,dynamic> toJson(){
    return _json;
  }
  
  @override
  List<Object?> get props => [userId];

}