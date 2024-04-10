import 'package:equatable/equatable.dart';

class Product extends Equatable{
  final Map<dynamic,dynamic> _json;
  const Product.fromJson({required final Map<dynamic,dynamic> json}):_json=json;

  String get productId => _json["productId"];
  
  @override
  List<Object?> get props => [productId];

  


}