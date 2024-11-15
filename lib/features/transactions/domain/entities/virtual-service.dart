import 'package:troco/core/extensions/list-extension.dart';
import 'package:troco/features/transactions/utils/enums.dart';
import 'package:troco/features/transactions/utils/virtual-service-requirement-converter.dart';

import '../../data/models/virtual-document.dart';
import '../../utils/task-status.dart';
import 'sales-item.dart';

class VirtualService extends SalesItem {
  final Map<dynamic, dynamic> _json;

  VirtualService.fromJson({required final Map<dynamic, dynamic> json})
      : _json = json,
        super(
            id: json["serviceId"] ?? json["_id"],
            name: json["virtualName"] ?? json["name"],
            price: double.parse(
                (json["virtualPrice"] ?? json["price"]).toString()),
            images: ((json["pricingImage"] ?? []) as List).toListString(),
            quantity: int.parse((json["quantity"] ?? 0).toString()));

  String get description =>
      _json["description"] ?? "Description Of this Virtual Product";

  String get proofOfTask =>
      _json["proofOfWork"] != null ? _proofOfWorkList.first : "";

  List<String> get _proofOfWorkList {
    try {
      return ((_json["proofOfWork"] ?? []) as List)
          .map(
            (e) => e.toString(),
          )
          .toList();
    } on TypeError catch (e) {
      final list = <String>[];
      list.add(_json["proofOfWork"] ?? "");
      return list;
    }
  }

  List<VirtualDocument> get virtualDocuments {
    return _proofOfWorkList
        .map(
          (e) => VirtualDocument(value: e, taskName: name),
        )
        .toList();
  }

  TaskStatus get status => TaskStatusConverter.toTaskStatus(
      status: _json["taskStatus"] ?? "Pending");

  TaskStatus get paymentStatus =>
      TaskStatusConverter.toTaskStatus(status: _json["payStatus"] ?? "Pending");

  /// [documentsUploaded] tells us if this virtual-item has it's parts
  bool get documentsUploaded => _proofOfWorkList.isNotEmpty;

  /// [clientSatisfied] tells us if the client has been satisfied with this task
  bool get clientSatisfied => _json["clientSatisfied"] ?? false;

  /// [paymentReleased] shows if payment has been added to Seller's wallet.
  bool get paymentReleased => _json["paymentReleased"] ?? false;

  /// [paymentMade] shows if payment has been made by the buyer.
  bool get paymentMade =>
      (_json["buyerPaid"] ?? false) && _json["buyerPaidProof"] != null;

  bool get workRejected => status == TaskStatus.Rejected;

  bool get approvePayment => paymentStatus == TaskStatus.Accepted;

  VirtualServiceRequirement get serviceRequirement =>
      VirtualServiceRequirementsConverter.convertToEnum(
          requirement:
              _json["virtualRequirement"] ?? _json["requirement"] ?? "design");

  @override
  Map toJson() {
    return _json;
  }
}
