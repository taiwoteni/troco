import 'package:equatable/equatable.dart';
import 'package:intl/intl.dart';
import 'package:troco/features/transactions/utils/enums.dart';
import 'package:troco/features/transactions/utils/product-condition-converter.dart';

class Product extends Equatable {
  final Map<dynamic, dynamic> _json;
  const Product.fromJson({required final Map<dynamic, dynamic> json})
      : _json = json;

  String get productId => _json["productId"] ?? _json["_id"];
  String get productName => _json["productName"];
  String get productPriceString =>
      NumberFormat.currency(locale: "en_NG", decimalDigits: 2, symbol: "")
          .format(productPrice);
  int get productPrice => _json["productPrice"] ?? _json["price"];
  ProductCondition get productCondition =>
      ProductConditionConverter.convertToEnum(
          condition: _json["productCondition"]);
  int get quantity => _json["quantity"];
  List<String> get productImages =>
      (_json["productImages"] as List).map((e) => e.toString()).toList();

  Map<dynamic, dynamic> toJson() {
    return _json;
  }

  @override
  List<Object?> get props => [productId];
}
