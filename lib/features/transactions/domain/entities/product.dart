import 'package:equatable/equatable.dart';
import 'package:intl/intl.dart';
import 'package:troco/features/transactions/utils/enums.dart';
import 'package:troco/features/transactions/utils/product-condition-converter.dart';

class Product extends Equatable {
  final Map<dynamic, dynamic> _json;
  const Product.fromJson({required final Map<dynamic, dynamic> json})
      : _json = json;

  String get productId => _json["productId"];
  String get productName => _json["productName"];
  String get productPriceString =>
      NumberFormat.currency(locale: "en_NG", decimalDigits: 0, symbol: "")
          .format(_json["productPrice"]);
  double get productPrice =>
      double.parse((_json["productPrice"] as double).toStringAsFixed(2));
  ProductCondition get productCondition =>
      ProductConditionConverter.convertToEnum(
          condition: _json["productCondition"]);
  int get quantity => _json["quantity"];
  List<String> get productImages => _json["productImages"];

  @override
  List<Object?> get props => [productId];
}
