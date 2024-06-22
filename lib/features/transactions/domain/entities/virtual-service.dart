import 'package:troco/features/transactions/utils/enums.dart';
import 'package:troco/features/transactions/utils/virtual-service-requirement-converter.dart';

import 'sales-item.dart';

class VirtualService extends SalesItem {
  final Map<dynamic, dynamic> _json;

  VirtualService.fromJson({required final Map<dynamic, dynamic> json})
      : _json = json,
        super(
            id: json["serviceId"] ?? json["_id"],
            name: json["serviceName"] ?? json["name"],
            price:
                int.parse((json["servicePrice"] ?? json["price"]).toString()),
            image: (json["serviceImages"] as List)
                .map((e) => e.toString())
                .toList()[0],
            quantity: int.parse(json["quantity"].toString()));


   VirtualServiceRequirement get serviceRequirement =>
      VirtualServiceRequirementsConverter.convertToEnum(
          requirement:
              _json["serviceRequirement"] ?? _json["requirement"] ?? "design");        

  @override
  Map toJson() {
    return _json;
  }
}
