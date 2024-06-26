import 'package:troco/features/transactions/utils/enums.dart';
import 'package:troco/features/transactions/utils/service-requirement-converter.dart';

import 'sales-item.dart';

class Service extends SalesItem {
  final Map<dynamic, dynamic> _json;
  Service.fromJson({required final Map<dynamic, dynamic> json})
      : _json = json,
        super(
            id: json["serviceId"] ?? json["_id"],
            name: json["serviceName"] ?? json["name"],
            price:
                int.parse((json["servicePrice"] ?? json["price"]).toString()),
            image: json["pricingImage"],
            quantity: int.parse((json["quantity"]??0).toString()));

  ServiceRequirement get serviceRequirement =>
      ServiceRequirementsConverter.convertToEnum(
          requirement:
              _json["serviceRequirement"] ?? _json["requirement"] ?? "design");
  List<String> get serviceImages =>
      (_json["pricingImage"] as List).map((e) => e.toString()).toList();

  

  @override
  Map toJson() {
    return _json;
  }
}
