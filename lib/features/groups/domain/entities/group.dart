import 'package:equatable/equatable.dart';
import 'package:troco/features/groups/data/models/group-member-model.dart';

class Group extends Equatable {
  final Map<dynamic, dynamic> _json;
  const Group.fromJson({required final Map<dynamic, dynamic> json})
      : _json = json;

  String get groupName => _json["groupName"] ?? _json["name"];
  DateTime get transactionTime =>
      DateTime.parse(_json["transactionTime"] ?? _json["deadlineTime"]);
  DateTime get createdTime => DateTime.parse(_json["creationTime"]);
  bool get usingDelivery => _json["useDelivery"];

  List<GroupMemberModel> get members {
    // List<dynamic> membersJson = json.decode(_json["members"] ?? "[]");
    // return membersJson
    //     .map((json) => GroupMemberModel.fromJson(json: json))
    //     .toList();
    return [];
  }

  String get groupId => _json["id"] ?? _json["_id"];
  String get adminId => _json["adminId"];

  Map<dynamic,dynamic> toJson(){
    return _json;
  }

  @override
  List<Object?> get props => [groupId];
}
