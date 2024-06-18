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
            image: (json["serviceImages"] as List).map((e) => e.toString()).toList()[0],
            quantity: int.parse(json["quantity"].toString()));

  ServiceRequirement get serviceRequirement =>
      ServiceRequirementsConverter.convertToEnum(
          requirement:
              _json["serviceRequirement"] ?? _json["requirement"] ?? "design");
  List<String> get serviceImages =>
      (_json["productImages"] as List).map((e) => e.toString()).toList();

  @override
  Map toJson() {
    throw UnimplementedError();
  }
}
