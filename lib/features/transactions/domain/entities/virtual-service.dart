import 'package:troco/features/transactions/utils/enums.dart';
import 'package:troco/features/transactions/utils/virtual-service-requirement-converter.dart';

import 'sales-item.dart';

class VirtualService extends SalesItem {
  final Map<dynamic, dynamic> _json;

  VirtualService.fromJson({required final Map<dynamic, dynamic> json})
      : _json = json,
        super(
            id: json["serviceId"] ?? json["_id"],
            name: json["virtualName"] ?? json["name"],
            price:
                int.parse((json["virtualPrice"] ?? json["price"]).toString()),
            image: json["pricingImage"],
            quantity: int.parse((json["quantity"]??0).toString()));


   VirtualServiceRequirement get serviceRequirement =>
      VirtualServiceRequirementsConverter.convertToEnum(
          requirement:
              _json["virtualRequirement"] ?? _json["requirement"] ?? "design");        

  @override
  Map toJson() {
    return _json;
  }
}
