import 'package:troco/core/extensions/list-extension.dart';
import 'package:troco/features/transactions/utils/enums.dart';
import 'package:troco/features/transactions/utils/service-requirement-converter.dart';

import '../../utils/task-status.dart';
import 'sales-item.dart';

class Service extends SalesItem {
  final Map<dynamic, dynamic> _json;
  Service.fromJson({required final Map<dynamic, dynamic> json})
      : _json = json,
        super(
            id: json["serviceId"] ?? json["_id"],
            name: json["serviceName"] ?? json["name"],
            price:
                double.parse((json["servicePrice"] ?? json["price"]).toString())
                    .toInt(),
            images: ((json["pricingImage"] ?? []) as List).toListString(),
            quantity: int.parse((json["quantity"] ?? 1).toString()));

  DateTime get deadlineTime => DateTime.parse(_json["deadlineTime"] ??
      _json["deadline"] ??
      DateTime.now().toIso8601String());
  ServiceRequirement get serviceRequirement =>
      ServiceRequirementsConverter.convertToEnum(
          requirement:
              _json["serviceRequirement"] ?? _json["requirement"] ?? "design");

  String get proofOfTask => _json["proofOfWork"] ?? "";

  TaskStatus get status => TaskStatusConverter.toTaskStatus(
      status: _json["taskStatus"] ?? "Pending");

  /// [taskUploaded] tells us if this task has it's work uploaded by the developer
  bool get taskUploaded => _json["proofOfWork"] != null;

  /// [clientSatisfied] tells us if the client has been satisfied with this task
  bool get clientSatisfied => _json["clientSatisfied"] ?? false;

  /// [paymentReleased] shows if payment has been added to Developers wallet.
  bool get paymentReleased => _json["paymentReleased"] ?? false;

  /// [paymentMade] shows if payment has been added to Developers wallet.
  bool get paymentMade =>
      (_json["buyerPaid"] ?? false) && _json["buyerPaidProof"] != null;

  bool get workRejected => status == TaskStatus.Rejected;

  bool get approvePayment => status == TaskStatus.Accepted;

  List<String> get serviceImages =>
      ((_json["pricingImage"] ?? []) as List).toListString();

  @override
  Map toJson() {
    return _json;
  }
}
