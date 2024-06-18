import 'package:troco/features/transactions/domain/entities/sales-item.dart';
import 'package:troco/features/transactions/utils/enums.dart';
import 'package:troco/features/transactions/utils/product-condition-converter.dart';
import 'package:troco/features/transactions/utils/product-quality-converter.dart';

class Product extends SalesItem {
  final Map<dynamic, dynamic> _json;
  Product.fromJson({required final Map<dynamic, dynamic> json})
      : _json = json,
        super(
          id: json["productId"] ?? json["_id"],
          price: int.parse((json["productPrice"] ?? json["price"]).toString()),
          name: json["productName"] ?? json["name"],
          image: (json["productImages"] as List).map((e) => e.toString()).toList()[0],
          quantity: int.parse(json["quantity"].toString()),
        );

  ProductCondition get productCondition =>
      ProductConditionConverter.convertToEnum(
          condition: _json["productCondition"] ?? _json["condition"] ?? "new");
  ProductQuality get productQuality => ProductQualityConverter.convertToEnum(
      quality: _json["productQuality"] ?? _json["quality"] ?? "high quality");
  String get productCategory =>
      _json["category"] ??
      _json["productCategory"] ??
      _json["category"] ??
      "No Category";
  List<String> get productImages =>
      (_json["productImages"] as List).map((e) => e.toString()).toList();

  @override
  List<Object?> get props => [id];

  @override
  Map toJson() => _json;
}
