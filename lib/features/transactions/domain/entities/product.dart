import 'package:troco/core/extensions/list-extension.dart';
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
          price:
              double.parse((json["productPrice"] ?? json["price"]).toString()),
          name: json["productName"] ?? json["name"],
          images: ((json["pricingImage"] ?? []) as List).toListString(),
          quantity: int.parse((json["quantity"] ?? 0).toString()),
        );

  ProductCondition get productCondition =>
      ProductConditionConverter.convertToEnum(
          condition: _json["productCondition"] ?? _json["condition"] ?? "new");
  ProductQuality get productQuality => ProductQualityConverter.convertToEnum(
      quality: _json["productQuality"] ??
          _json["quality"] ??
          _json["category"] ??
          "high quality");
  String get productCategory =>
      _json["category"] ??
      _json["productCategory"] ??
      _json["category"] ??
      "No Category";
  List<String> get productImages =>
      ((_json["pricingImage"] ?? []) as List).toListString();

  @override
  List<Object?> get props => [id];

  @override
  Map toJson() => _json;
}
