import 'dart:convert';
import 'package:troco/features/groups/data/models/group-member-model.dart';

class GroupModel {
  final Map<dynamic, dynamic> _json;
  const GroupModel.fromJson({required final Map<dynamic, dynamic> json})
      : _json = json;

  String get groupName => _json["groupName"];
  DateTime get transactionTime => DateTime.parse(_json["transactionTime"]);
  DateTime get createdTime => DateTime.parse(_json["creationTime"]);
  bool get usingDelivery => _json["useDelivery"];

  List<GroupMemberModel> get members {
    List<dynamic> membersJson = json.decode(_json["members"] ?? "[]");
    return membersJson
        .map((json) => GroupMemberModel.fromJson(json: json))
        .toList();
  }

  String get id => _json["id"];
  String get adminId => _json["adminId"];
}
